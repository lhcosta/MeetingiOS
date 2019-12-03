//
//  User.swift
//  MeetingiOS
//
//  Created by Caio Azevedo on 26/11/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import Foundation
import CloudKit

class User {
    
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
    
    // reuniões vindos da entidade Reunião
    var meetings: [CKRecord.Reference]?{
        didSet {
            self.record.setValue(meetings, forKey: "meetings")
        }
    }
    
    //MARK: - Initializer
    init(record: CKRecord) {
        self.record = record
        self.email = record.value(forKey: "email") as? String
        self.name = record.value(forKey: "name") as? String
        self.meetings = record.value(forKey: "meetings") as? [CKRecord.Reference]
    }
    
    //MARK: - Methods
    
    /// Description: Procura o AppleIDCredential do usuário para caso o usuário tenha logado no app uma vez
    /// - Parameter record: credencial vinda do Sign in with apple
    func searchCredentials(record: CKRecord){
        CloudManager.shared.fetchRecords(recordIDs: [record.recordID], desiredKeys: ["email", "name", "invites", "meetings"]) { (records, error) in
            guard let rec = records?[record.recordID] else {
                //Criar pessoa do zero
                return

            }
            self.email = rec.value(forKey: "email") as? String
            self.name = rec.value(forKey: "name") as? String
            self.meetings = rec.value(forKey: "meetings") as? [CKRecord.Reference]
        }
    }
    
    // Registra uma reunião no array de reuniões do usuário
    func registerMeeting(meeting: CKRecord.Reference){
        self.meetings?.append(meeting)
        self.record.setValue(meetings, forKey: "meetings")
    }
    
    
    /// Busca no vetor e deleta reunião do array de reuniões
    /// - Parameter
    /// meetingReference: é o CKRecord.Reference da reunião que deseja deletar do array
    func removeMeeting(meetingReference: CKRecord.Reference){
        var  i = 0
        for met in meetings! {
            if met == meetingReference{
                meetings?.remove(at: i)
            }
            i += 0
        }
    }
}
