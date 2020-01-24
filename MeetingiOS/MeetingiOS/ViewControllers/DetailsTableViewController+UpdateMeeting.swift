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
    @objc func updateMeeting() {
        
        let loadingAlertIndicator = self.detailsManagerController.createAlertLoadingIndicator(message: NSLocalizedString("Meeting update...", comment: ""))
        
        self.present(loadingAlertIndicator, animated: true, completion: nil)
        
        updateMeetingUsers { (users) in
            
            DispatchQueue.main.async {
                
                guard let name = self.meetingName?.text else {return}
                guard let numberOfTopics = Int(self.topicsPerPerson?.text ?? "1") else {return}
                guard let initialDate = self.startsDate?.text, let finalDate = self.endesDate?.text else {return}
                
                self.meeting.theme = name
                self.meeting.limitTopic = Int64(numberOfTopics)
                self.meeting.initialDate = self.formatter.date(from: initialDate)
                self.meeting.finalDate = self.formatter.date(from: finalDate)
                self.meeting.addingNewEmployees(users)
                
                CloudManager.shared.updateRecords(records: [self.meeting.record], perRecordCompletion: { (_, error) in
                    
                    if let error = error as NSError? {
                        NSLog("%@", error.userInfo)
                        return
                    }
                    
                }) { 
                    DispatchQueue.main.async {
                        loadingAlertIndicator.dismiss(animated: true) { 
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            } 
            
            self.detailsManagerController.updateUsers(users: users, meeting: self.meeting, typeUpdate: .insertUser)
        }
    }
    
    /// Buscando novos usuários que foram selecionados e removendo os deselecionados
    /// - Parameter completionHandler: todos os contatos que foram selecionados e possuem cadastro.
    private func updateMeetingUsers(completionHandler : @escaping ([User]) -> Void) {
        
        //Novos usuários
        var newUsers = [User]()
        
        // Novos contatos
        let selectedContacts = self.contactCollectionView.contacts
        
        /// Usuários antigos
        guard let oldUsers = self.employees_user.copy() as? [User] else {return}
        
        //Apenas os contatos que não são usuários ainda.
        let onlyContacts = selectedContacts.filter { (contact) -> Bool in
            return !oldUsers.contains(where: { 
                return $0.email == contact.email
            })
        }
        
        self.detailsManagerController.getUsersFromSelectedContact(contacts: onlyContacts) { (users) in
            if let new_users = users {
                newUsers = new_users
            }
            
            completionHandler(newUsers)
        }
        
        //Usuários removidos da reunião
        let removeUsers = oldUsers.filter { (user) -> Bool in
            !selectedContacts.contains(where: {
                return $0.email == user.email
            })
        }
        
        self.meeting.removingEmployees(removeUsers)
        self.detailsManagerController.updateUsers(users: removeUsers, meeting: meeting, typeUpdate: .deleteUser)
    }
}
