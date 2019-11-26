//
//  ViewController.swift
//  MeetingiOS
//
//  Created by Bernardo Nunes on 21/11/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import UIKit
import AuthenticationServices

class LoginViewController: UIViewController {

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
        
        // Auto Layout do botão
        NSLayoutConstraint.activate([
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            signInButton.heightAnchor.constraint(equalToConstant: 40),
            signInButton.widthAnchor.constraint(equalToConstant: 200)
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
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    
    // Após obter a autoriização é possíivel obter as informações necessárias (email, fullname)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }
        
        print("AppleID Credential Authorization: userId: \(appleIDCredential.user), email: \(String(describing: appleIDCredential.email)), name: \(String(describing: appleIDCredential.fullName))")
        
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
