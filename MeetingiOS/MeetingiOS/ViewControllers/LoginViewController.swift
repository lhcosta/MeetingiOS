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
    var goingToProfile = false
    @IBOutlet private weak var stackView : UIStackView!
    
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
        let authorizationProvider = ASAuthorizationAppleIDProvider()
        let request = authorizationProvider.createRequest()
        // Especifíca quais informações pedir autorização
        request.requestedScopes = [.email, .fullName]
        
        // Cria a controller responsável por efetuar o login

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self as ASAuthorizationControllerDelegate
        authorizationController.presentationContextProvider = self as ASAuthorizationControllerPresentationContextProviding
        authorizationController.performRequests()
        
    }
    
    func getAppleIDStatus(userIdentifier: String) {
        
        let provider = ASAuthorizationAppleIDProvider()
        provider.getCredentialState(forUserID: userIdentifier) { (credentialState, error) in
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
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }
        
//        getAppleIDStatus(userIdentifier: appleIDCredential.user)
        
        print("AppleID Credential Authorization: userId: \(appleIDCredential.user), email: \(String(describing: appleIDCredential.email)), name: \(String(describing: appleIDCredential.fullName))")
        
        // Criação do Record na tabela de Usuários no Cloud
        let userRecord = CKRecord(recordType: "User", recordID: CKRecord.ID(recordName: appleIDCredential.user))
        
        // Passagem do record no construtor da Struct
        let user = User.init(record: userRecord)
        
        let givenName = appleIDCredential.fullName?.givenName
        let familyName = appleIDCredential.fullName?.familyName
        
        // Se email = nil, faz-se o fetch dos dados do Usuário com base no appleIDCredential
        if let email = appleIDCredential.email {
            // Popula o Record na Struct User
            user.email = String(describing: email)
            
            user.name = "\(String(describing: givenName!)) \(String(describing: familyName!))"
            self.saveDefaults(user: user)
            self.notificationPermission()
            self.goToNextVC()
            // Cria o record no Cloud
            CloudManager.shared.createRecords(records: [userRecord], perRecordCompletion: { (record, error) in
                if let error = error {
                    print("Error: \(error)")
                } else {
                    print("Successfully created user: ", record["name"]!)
                    print(record.recordID.recordName)
                    self.defaults.set(user.record.recordID.recordName, forKey: "recordName")
                }
            }) {
                print("Done")
            }
            
        } else {
            let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: -10, y: 5, width: 50, height: 50))
            activityIndicator.style = .medium
            activityIndicator.hidesWhenStopped = true
            activityIndicator.startAnimating()
            
            let loadingAlert = UIAlertController(title: nil, message: "Loading", preferredStyle: .alert)
            loadingAlert.view.addSubview(activityIndicator)
            
            self.present(loadingAlert, animated: true){
                user.searchCredentials(record: userRecord){ _ in
                    print("User Email: \(String(describing: user.email))")
                    self.defaults.set(user.record.recordID.recordName, forKey: "recordName")
                    self.saveDefaults(user: user)
                    DispatchQueue.main.async {
                        loadingAlert.dismiss(animated: true, completion: nil)
                        self.notificationPermission()
                        self.goToNextVC()
                    }
                }
            }
        }
    }
    
    private func notificationPermission(){
        let application = UIApplication.shared
        let userNotCenter = UNUserNotificationCenter.current()
        userNotCenter.delegate = application.delegate as! AppDelegate
        
        userNotCenter.requestAuthorization(options: [.providesAppNotificationSettings], completionHandler: { (permission, error) in
            print("===>\(permission)/\(String(describing: error))")
        })
        
        DispatchQueue.main.async {
            application.registerForRemoteNotifications()
        }
    }
    
    private func goToNextVC(){
        if goingToProfile {
            let storyboard = UIStoryboard(name: "Profile", bundle: nil)
            let nextVC = storyboard.instantiateInitialViewController() as! ProfileViewController
            nextVC.didComeFromLogin = true
            self.present(nextVC, animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func saveDefaults(user: User) {
        self.defaults.set(user.name, forKey: "givenName")
        self.defaults.set(user.email, forKey: "email")
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
