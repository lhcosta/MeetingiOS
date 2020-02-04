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

    /// Pegando todos os usuários já cadastrados dos contatos selecionados.
    /// - Parameters:
    ///   - contacts: contatos selecionados.
    ///   - completionHandler: usuários que já possuem cadastro.
    @objc func getUsersFromSelectedContact(contacts : [Contact], completionHandler : @escaping ([User]?) -> Void) {
        
        if contacts.count == 0 {
            completionHandler(nil)
            return
        }
        
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
    
    /// Atualização dos usuários.
    /// - Parameters:
    ///   - users: usuários escolhidos.
    ///   - meeting: reunião atual.
    ///   - typeUpdate: insercao ou delecao de reunioes.
    @objc func updateUsers(users : [User], meeting : Meeting, typeUpdate : TypeUpdateUser) {
        
        if(users.count != 0) {
            
            if typeUpdate == .insertUser {
                users.forEach {
                    $0.registerMeeting(meeting: CKRecord.Reference(record: meeting.record, action: .none))
                }
            } else {
                users.forEach {
                    $0.removeMeeting(meetingReference: meeting.record.recordID)
                }
            }
            
            CloudManager.shared.updateRecords(records: users.map({ return $0.record }), perRecordCompletion: { (record, error) in
                if let error = error as NSError? {
                    NSLog("Update User -> %@", error.userInfo)
                }
                
            }) { 
                print("Updated Users")
            }
        }
    }
}
