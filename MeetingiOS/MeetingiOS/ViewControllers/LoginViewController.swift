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
        self.view.addSubview(signInButton)
        
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Auto Layout do botão
        NSLayoutConstraint.activate([
            signInButton.widthAnchor.constraint(equalToConstant: 200),
            signInButton.heightAnchor.constraint(equalToConstant: 40),
            signInButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            signInButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ])
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
            
            // Cria o record no Cloud
            CloudManager.shared.createRecords(records: [userRecord], perRecordCompletion: { (record, error) in
                if let error = error {
                    print("Error: \(error)")
                } else {
                    print("Successfully created user: ", record["name"]!)
                    self.saveDefaults(user: user)
                    print(record.recordID.recordName)
                }
            }) {
                print("Done")
            }
            
        } else {
            user.searchCredentials(record: userRecord){ _ in
                print("User Email: \(String(describing: user.email))")
                self.saveDefaults(user: user)
            }
        }
        
        self.performSegue(withIdentifier: "nextScreen", sender: nil)
    }
    
    private func saveDefaults(user: User) {
        self.defaults.set(user.record.recordID.recordName, forKey: "recordName")
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
