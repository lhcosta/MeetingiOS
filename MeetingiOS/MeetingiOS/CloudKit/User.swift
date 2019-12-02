//
//  User.swift
//  MeetingiOS
//
//  Created by Caio Azevedo on 26/11/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import Foundation
import CloudKit

struct User {
    
    //MARK: - Properties
    private(set) var record: CKRecord
    
    var appleCredential: String? {
        didSet {
            self.record.setValue(appleCredential, forKey: "appleCredential")
        }
    }
    
    var email: String? {
        didSet {
            self.record.setValue(email, forKey: "email")
        }
    }
    var name: String? {
        didSet {
            self.record.setValue(name, forKey: "name")
        }
    }
    
    // convites vindos da entidade Reunião
    var invites: [CKRecord.Reference]? {
        didSet {
            self.record.setValue(invites, forKey: "invites")
        }
    }
    
    // reuniões vindos da entidade Reunião
    var meetings: [CKRecord.Reference]?{
        didSet {
            self.record.setValue(meetings, forKey: "meetings")
        }
    }
    
    //MARK: - Initializer
    init(record: CKRecord) {
        self.record = record
        self.appleCredential = record.value(forKey: "appleCredential") as? String
        self.email = record.value(forKey: "email") as? String
        self.name = record.value(forKey: "name") as? String
        self.invites = record.value(forKey: "invites") as? [CKRecord.Reference]
        self.meetings = record.value(forKey: "meetings") as? [CKRecord.Reference]
    }
    
    //MARK: - Methods
    
    /// Description: Procura o AppleIDCredential do usuário para caso o usuário tenha logado no app uma vez
    /// - Parameter credential: credencial vinda do Sign in with apple
    mutating func searchCredentials(credential: String, record: CKRecord){
        CloudManager.shared.fetchRecords(recordIDs: [record.recordID], desiredKeys: ["email", "name", "invites", "meetings"]) { (records, error) in
            let rec = records![record.recordID]
            User(record: rec!)
        }
    }
    
    // Adiciona o convite no array de convites do Usuario
    mutating func addInvite(invite: CKRecord.Reference){
        self.invites?.append(invite)
        self.record.setValue(invites, forKey: "invites")
    }
    
    // Remove o convite do array de convites do Usuario (no caso de aceitar ou recusar um convite)
    mutating func removeInvite(inviteReference: CKRecord.Reference){
        var  i = 0
        for inv in invites! {
            if inv == inviteReference{
                invites?.remove(at: i)
            }
            i += 0
        }
    }
    
    // Registra uma reunião no array de reuniões do usuário
    mutating func registerMeeting(meeting: CKRecord.Reference){
        self.meetings?.append(meeting)
        self.record.setValue(meetings, forKey: "meetings")
    }
    
    
    /// Busca no vetor e deleta reunião do array de reuniões
    /// - Parameter
    /// meetingReference: é o CKRecord.Reference da reunião que deseja deletar do array
    mutating func removeMeeting(meetingReference: CKRecord.Reference){
        var  i = 0
        for met in meetings! {
            if met == meetingReference{
                meetings?.remove(at: i)
            }
            i += 0
        }
    }
}
