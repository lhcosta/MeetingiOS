//
//  User.swift
//  MeetingiOS
//
//  Created by Caio Azevedo on 26/11/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import Foundation
import CloudKit

@objc class User : NSObject {
    
    //MARK: - Properties
    private(set) var record: CKRecord
    
    var appleCredential: String? {
        get {
            return self.record.value(forKey: "appCredential") as? String
        }
        
        set {
            self.record.setValue(newValue, forKey: "appCredential")
        }
    }
    
    var email: String? {
        
        get {
            return self.record.value(forKey: "email") as? String
        }
        
        set {
            self.record.setValue(newValue, forKey: "email")
        }
    }
    
    var name: String? {
        
        get {
            return self.record.value(forKey: "name") as? String
        }
        
        set {
            self.record.setValue(newValue, forKey: "name")
        }
    }
    
    
    // reuniões vindos da entidade Reunião
    var meetings: [CKRecord.Reference]?{
        get {
            return self.record.value(forKey: "meetings") as? [CKRecord.Reference]
        }
        
        set {
            self.record.setValue(newValue, forKey: "meetings")
        }
    }
    
    //MARK: - Initializer
    @objc init(record: CKRecord) {
        self.record = record
    }
    
    //MARK: - Methods
    
    /// Description: Procura o AppleIDCredential do usuário para caso o usuário tenha logado no app uma vez
    /// - Parameter record: credencial vinda do Sign in with apple
    func searchCredentials(record: CKRecord, compleetion: @escaping ((Bool) -> Void)){
        CloudManager.shared.fetchRecords(recordIDs: [record.recordID], desiredKeys: ["email", "name", "meetings"]) { (records, error) in
            print("Error: \(error)")
            guard let rec = records?[record.recordID] else { return }
            
            // Atualiza os dados do Usuário
            self.email = rec.value(forKey: "email") as? String
            self.name = rec.value(forKey: "name") as? String
            self.meetings = rec.value(forKey: "meetings") as? [CKRecord.Reference]
            
            print("\(String(describing: rec.value(forKey: "email") as? String))")
            
            compleetion(true)
        }
    }
    
    // Registra uma reunião no array de reuniões do usuário
    @objc func registerMeeting(meeting: CKRecord.Reference){
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
