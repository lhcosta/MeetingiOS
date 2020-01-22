//
//  DetailsTableViewController+UpdateMeeting.swift
//  MeetingiOS
//
//  Created by Lucas Costa  on 22/01/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

import Foundation

extension DetailsTableViewController {
    
    @objc func updateMeeting() {
        
        separateUsersAndContacts()
    }
    
    private func separateUsersAndContacts() {
        
        //Novos usuários
        var newUsers = [User]()
        
        // Novos contatos
        let newContacts = self.contactCollectionView.contacts
        
        /// Usuários antigos
        guard let oldUsers = self.employees_user.copy() as? [User] else {return}
        
        //Usuários que não foram removidos da reunião
        let continueUsers = oldUsers.filter { (user) -> Bool in
            return newContacts.contains(where: {
                return $0.email == user.email
            })            
        }
        
        newUsers.append(contentsOf: continueUsers)
        
        //Apenas os contatos que não são usuários ainda.
        let onlyContacts = newContacts.filter { (contact) -> Bool in
            return !oldUsers.contains(where: { 
                return $0.email == contact.email
            })
        }
        
        newUsers.append(contentsOf: fetchNewUsers(contacts: onlyContacts))
        
        //Usuários removido da reunião
        let removeUsers = oldUsers.filter { (user) -> Bool in
            !newContacts.contains(where: {
                return $0.email == user.email
            })
        }
        
        updateRemovedUsers(removeUsers: removeUsers)
        
    }
    
    /// Buscando a existência do contato no cloud e o transformando em record.
    /// - Parameter contacts: contatos a serem buscados.
    private func fetchNewUsers(contacts : [Contact]) -> [User] {
        
        var newUsers = [User]()
        
        let allEmails = contacts.compactMap { (contact) -> String? in
            return contact.email
        }
        
        let predicate = NSPredicate(format: "email IN %@", allEmails)
        
        CloudManager.shared.readRecords(recorType: "User", predicate: predicate, desiredKeys: ["recordName"], perRecordCompletion: { (record) in
            
            let user = User(record: record)
            user.meetings.append(CKRecord.Reference(record: self.meeting.record, action: .none))
            newUsers.append(user)
            
        }) { 
            print("Fetched new users")
        }
        
        return newUsers
    }
    
    /// Atualizando usuários removidos da reunião.
    private func updateRemovedUsers(removeUsers : [User]) {
        
        removeUsers.forEach {
            $0.removeMeeting(meetingReference: self.meeting.record.recordID)
        }
        
        let records = removeUsers.map { (user) -> CKRecord in
            return user.record
        }
        
        CloudManager.shared.updateRecords(records: records, perRecordCompletion: { (record, error) in
            if let error = error as NSError? {
                print("Error - Update user -> \(error.userInfo)")
            }
        }) { 
            print("Update all users")
        }
    }
}
