//
//  DetailsTableViewController+UpdateMeeting.swift
//  MeetingiOS
//
//  Created by Lucas Costa  on 22/01/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

import Foundation

extension DetailsTableViewController {
    
    /// Atualização da reunião.
    @objc func updatingMeeting() {
    
        let loadingAlertIndicator = UIAlertController(title: nil, message: NSLocalizedString("Meeting update...", comment: ""), preferredStyle: .alert)
        loadingAlertIndicator.addUIActivityIndicatorView()
        
        self.present(loadingAlertIndicator, animated: true, completion: nil)
        
        updateMeetingUsers { (users) in
            
            DispatchQueue.main.async {
                
                if let name = self.meetingName?.text, !name.isEmpty {
                    self.meeting.theme = name
                }
                
                guard let numberOfTopics = Int(self.topicsPerPerson?.text ?? "1") else {return}
                guard let initialDate = self.startsDate?.text, let finalDate = self.endesDate?.text else {return}
            
                self.meeting.limitTopic = Int64(numberOfTopics)
                self.meeting.initialDate = self.formatter.date(from: initialDate)
                self.meeting.finalDate = self.formatter.date(from: finalDate)
                
                if let users = users {
                    self.meeting.addingNewEmployees(users)
                }
                            
                CloudManager.shared.updateRecords(records: [self.meeting.record], perRecordCompletion: { (_, error) in
                    
                    if let error = error as NSError? {
                        NSLog("%@", error.userInfo)
                        return
                    }
                    
                }) { 
                    DispatchQueue.main.async {
                        loadingAlertIndicator.dismiss(animated: true, completion: {
                            self.dismiss(animated: true, completion: nil)
                        })
                    }
                }
            } 
            
            if let users = users {
                self.detailsManagerController.updateUsers(users: users, meeting: self.meeting, typeUpdate: .insertUser)
            }
        }
    }
    
    /// Buscando novos usuários que foram selecionados e removendo os deselecionados
    /// - Parameter completionHandler: todos os contatos que foram selecionados e possuem cadastro.
    private func updateMeetingUsers(completionHandler : @escaping ([User]?) -> Void) {
                
        if let newContacts = fetchNewContacts() {
            self.detailsManagerController.getUsersFromSelectedContact(contacts: newContacts) { (users) in
                if let newUsers = users {
                    completionHandler(newUsers)
                } else {
                    completionHandler(nil)
                }
            }
        }
        
        if let removeUsers = self.fetchRemovedUsers() {
            self.meeting.removingEmployees(removeUsers)
            self.detailsManagerController.updateUsers(users: removeUsers, meeting: meeting, typeUpdate: .deleteUser)
        }
    }
    
    /// Moficação nos participantes da reunião.
    @objc func hasMoficationInParticipants() -> Bool {
        
        let newContacts = fetchNewContacts() ?? []
        let removeUsers = fetchRemovedUsers() ?? []
        
        return (newContacts.count != 0) || (removeUsers.count != 0)
    }
    
    /// Novos contatos selecionados.
    private func fetchNewContacts() -> [Contact]? {
        
        // Novos contatos
        let selectedContacts = self.contactCollectionView.contacts
        
        /// Usuários antigos
        guard let oldUsers = self.employees_user.copy() as? [User] else {return nil}
        
        //Apenas os contatos que não são usuários ainda.
        let newContacts = selectedContacts.filter { (contact) -> Bool in
            return !oldUsers.contains(where: { 
                return $0.email == contact.email
            })
        }
        
        return newContacts
    }
    
    /// Usuários removidos.
    private func fetchRemovedUsers() -> [User]? {
        
        // Novos contatos
        let selectedContacts = self.contactCollectionView.contacts
        
        /// Usuários antigos
        guard let oldUsers = self.employees_user.copy() as? [User] else {return nil}
        
        //Usuários removidos da reunião
        let removeUsers = oldUsers.filter { (user) -> Bool in
            !selectedContacts.contains(where: {
                return $0.email == user.email
            })
        }
        
        return removeUsers        
    }
}
