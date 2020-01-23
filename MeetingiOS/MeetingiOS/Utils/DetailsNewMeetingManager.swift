//
//  DetailsNewMeetingManager.swift
//  MeetingiOS
//
//  Created by Lucas Costa  on 22/01/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

import Foundation
import UIKit

/// Classe que contém métodos que são utilizados por New Meeting e Details.
@objc class DetailsNewMeetingManager : NSObject {
    
    //MARK:- CollectionViewContacts
    /// Inicializando a collection view de contatos.
    /// - Parameter collectionView: collection view para ser configurada.
    @objc func setupCollectionViewContacts(_ collectionView : UICollectionView) -> ContactCollectionView {
        
        let contactCollectionView = ContactCollectionView(removeContact: false)
        collectionView.dataSource = contactCollectionView
        collectionView.delegate = contactCollectionView
        collectionView.register(UINib(nibName: "ContactCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ContactCollectionCell")
        collectionView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        collectionView.layer.cornerRadius = 7
        
        return contactCollectionView
    }
    
    /// Criando uma view de loading.
    /// - Parameter message: texto para ser mostrado na alert de loading.
    @objc func createAlertLoadingIndicator(message : String) -> UIAlertController {
        
        let alertLoading = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(style: .medium)
        
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()
        
        alertLoading.view.addSubview(loadingIndicator)
        
        loadingIndicator.centerYAnchor.constraint(equalTo: alertLoading.view.centerYAnchor).isActive = true
        loadingIndicator.leadingAnchor.constraint(equalTo: alertLoading.view.leadingAnchor, constant: 20).isActive = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        return alertLoading
    }
    
    /// Pegando todos os usuários já cadastrados dos contatos selecionados.
    /// - Parameters:
    ///   - contacts: contatos selecionados.
    ///   - completionHandler: usuários que já possuem cadastro.
    @objc func getUsersFromSelectedContact(contacts : [Contact], completionHandler : @escaping ([User]) -> Void) {
        
        var users : [User] = []
        
        let emails = contacts.compactMap { (contact) -> String? in
            return contact.email
        }
        
        let predicate = NSPredicate(format: "email IN %@", emails)
        
        CloudManager.shared.readRecords(recorType: "User", predicate: predicate, desiredKeys: ["recordName"], perRecordCompletion: { (record) in
            users.append(User(record: record))
        }) { 
            completionHandler(users)
        }
    }
    
}
