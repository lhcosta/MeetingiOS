//
//  ViewController.swift
//  MeetingiOS
//
//  Created by Bernardo Nunes on 21/11/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import UIKit
import AuthenticationServices
import CloudKit

class LoginViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    @IBOutlet private weak var stackView : UIStackView!
    var isMyMeeting = false
    var loading : UIAlertController!
    
    var authorizationProvider : ASAuthorizationAppleIDProvider!
    
    /// Usuário
    private var user : User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupSignInButton()
    }
    
    private func setupSignInButton() {
        // Criação do Botão como um ASAuthorizationAppleIDButton
        let signInButton = ASAuthorizationAppleIDButton()
        
        // Dispara a ação de login do botão chamando o método signInButtonTapped
        signInButton.addTarget(self, action: #selector(LoginViewController.signInButtonTapped), for: .touchDown)
        
        // Adiciona o botão na tela
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Auto Layout do botão
        NSLayoutConstraint.activate([
            signInButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        self.stackView.addArrangedSubview(signInButton)
    }
    
    @objc private func signInButtonTapped() {
        //  Cria o provedor de autorização para obter as informações do Usuário
        self.authorizationProvider = ASAuthorizationAppleIDProvider()
        let request = authorizationProvider.createRequest()
        // Especifíca quais informações pedir autorização
        request.requestedScopes = [.email, .fullName]
        
        // Cria a controller responsável por efetuar o login
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self as ASAuthorizationControllerDelegate
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
        
    }
    
    func getAppleIDStatus(userIdentifier: String) {
        self.authorizationProvider.getCredentialState(forUserID: userIdentifier) { (credentialState, error) in
            switch(credentialState){
                case .authorized:
                    print("Autorizado")
                    break
                case .revoked:
                    print("Revogado")
                    break
                case .notFound:
                    print("Nao Encontrado")
                    break
                default: break
            }
        }
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    
    // Após obter a autoriização é possíivel obter as informações necessárias (email, fullname)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            getAppleIDStatus(userIdentifier: appleIDCredential.user)
            
            print("AppleID Credential Authorization: userId: \(appleIDCredential.user), email: \(String(describing: appleIDCredential.fullName)), name: \(String(describing: appleIDCredential.fullName))")
            
            self.loading = UIAlertController(title: "", message: "Loading...", preferredStyle: .alert)
            self.loading.addUIActivityIndicatorView()
            self.present(self.loading, animated: true, completion: nil)
            
            //Verificando a existencia do usuario no database
            CloudManager.shared.fetchRecords(recordIDs: [CKRecord.ID(recordName: appleIDCredential.user)], desiredKeys: ["recordName"]) { (records, error) in
                
                if let error = error {
                    print("User Login -> \(error)")
                }
                
                if let record = records?.first?.value {
                    self.user = User(record: record)
                    self.user.searchCredentials(record: record) { (_) in
                        self.saveDefaults(user: self.user)
                        self.confirmLoginInApp()
                    }
                } else {
                    self.createNewUserInCloud(appleIDCredential: appleIDCredential)
                }
            }
            
            
        }
        
    }
    
    /// Permiti o recebimento de notificações.
    private func notificationPermission(){
        let application = UIApplication.shared
        let userNotCenter = UNUserNotificationCenter.current()
        
        DispatchQueue.main.async {
            userNotCenter.delegate = application.delegate as! AppDelegate
        }
        
        userNotCenter.requestAuthorization(options: [.providesAppNotificationSettings], completionHandler: { (permission, error) in
            print("===>\(permission)/\(String(describing: error))")
            if permission {
                CloudManager.shared.subscribe()
            }
        })
        
        DispatchQueue.main.async {
            let application = UIApplication.shared
            let userNotCenter = UNUserNotificationCenter.current()
            userNotCenter.delegate = application.delegate as! AppDelegate
            
            userNotCenter.requestAuthorization(options: [.providesAppNotificationSettings], completionHandler: { (permission, error) in
                print("===>\(permission)/\(String(describing: error))")
                if permission {
                    CloudManager.shared.subscribe()
                }
            })
            
            application.registerForRemoteNotifications()
        }
    }
    
    private func confirmLoginInApp(){
        DispatchQueue.main.async {
            self.loading.dismiss(animated: true) { 
                self.dismiss(animated: true, completion: {
                    if self.isMyMeeting {
                        NotificationCenter.default.post(name: Notification.Name("UserLogin"), object: nil)
                    }
                })
            }
        }
    }
    
    private func saveDefaults(user: User) {
        self.defaults.set(user.record.recordID.recordName, forKey: "recordName")
        self.defaults.set(user.name, forKey: "givenName")
        self.defaults.set(user.email, forKey: "email")
    }
    
    /// Criando o usuário não existente no Cloud
    private func createNewUserInCloud(appleIDCredential : ASAuthorizationAppleIDCredential) {
        
        // Criação do Record na tabela de Usuários no Cloud
        let userRecord = CKRecord(recordType: "User", recordID: CKRecord.ID(recordName: appleIDCredential.user))
        
        // Passagem do record no construtor da Struct
        self.user = User(record: userRecord)
        
        if let email = appleIDCredential.email {
            user.email = email
        }
        
        // Popula o Record na Struct User
        if let name = appleIDCredential.fullName?.givenName {
            user.name = name
        }
        
        if let familyName = appleIDCredential.fullName?.familyName {
            user.name?.append(contentsOf: " \(familyName)")
        }
        
        self.saveDefaults(user: user)
        
        // Cria o record no Cloud
        CloudManager.shared.createRecords(records: [userRecord], perRecordCompletion: { (record, error) in
            if let error = error {
                print("Error: \(error)")
            } else {
                print("Successfully created user: ")
                self.notificationPermission()
            }
        }) {
            self.confirmLoginInApp()
            print("Done")
        }
    }
    
    // Para tratar erros
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("AppleID Credential failed with error: \(error.localizedDescription)")
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

