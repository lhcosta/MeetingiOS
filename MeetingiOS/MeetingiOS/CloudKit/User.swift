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
    @objc private(set) var record: CKRecord
    
    private static let defaults = UserDefaults.standard
    private static let cloud = CloudManager.shared
    
    var appleCredential: String? {
        get {
            return self.record.value(forKey: "appCredential") as? String
        }
        
        set {
            self.record.setValue(newValue, forKey: "appCredential")
        }
    }
    
    @objc var email: String? {
        
        get {
            return self.record.value(forKey: "email") as? String
        }
        
        set {
            self.record.setValue(newValue, forKey: "email")
        }
    }
    
    @objc var name: String? {
        
        get {
            return self.record.value(forKey: "name") as? String
        }
        
        set {
            self.record.setValue(newValue, forKey: "name")
        }
    }
    
    // reuniões vindos da entidade Reunião
    var meetings: [CKRecord.Reference]{
        get {
            return self.record.value(forKey: "meetings") as? [CKRecord.Reference] ?? []
        }
        
        set {
            self.record.setValue(newValue, forKey: "meetings")
        }
    }
    
    // Debug
    override var description: String {
        return "\(self.name ?? "Empty") -> \(self.email ?? "Empty")"
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
            
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let rec = records?[record.recordID] else { return }
            
            // Atualiza os dados do Usuário
            self.email = rec.value(forKey: "email") as? String
            self.name = rec.value(forKey: "name") as? String
            self.meetings = rec.value(forKey: "meetings") as? [CKRecord.Reference] ?? []
            
            print("\(String(describing: rec.value(forKey: "email") as? String))")
            
            compleetion(true)
        }
    }
    
    static func updateUser(name: String?, email: String?, completion: @escaping (() -> Void)) {
        
        guard let recordName = defaults.string(forKey: "recordName") else { return }
        let recordID = CKRecord.ID(recordName: recordName)
        let userCK = CKRecord(recordType: "User", recordID: recordID)
        var emailExists = false

        if let name = name {
            userCK.setValue(name, forKey: "name")
        }
        
        if let email = email {
            let predicate = NSPredicate(format: "email = %@", email)
            cloud.readRecords(recorType: "User", predicate: predicate, desiredKeys: ["recordName"], perRecordCompletion: { _ in
                emailExists = true
            }) {
                if emailExists {
                    print("email ja existente")
                } else {
                    userCK.setValue(email, forKey: "email")
                    if let name = name {
                        self.defaults.set(name, forKey: "givenName")
                    }
                    self.defaults.set(email, forKey: "email")
                    performUpdate(record: userCK)
                    completion()
                }
            }
        } else {
            self.defaults.set(name, forKey: "givenName")
            performUpdate(record: userCK)
            completion()
        }
    }
    
    static private func performUpdate(record: CKRecord) {
        cloud.updateRecords(records: [record], perRecordCompletion: { (_, error) in
            print(error ?? "Sem erro")
        }){
            print("Update complete")
        }
    }
    
    // Registra uma reunião no array de reuniões do usuário
    @objc func registerMeeting(meeting: CKRecord.Reference){
        self.meetings.append(meeting)  
    }
    
    /// Busca no vetor e deleta reunião do array de reuniões
    /// - Parameter meetingReference: é o CKRecord.Reference da reunião que deseja deletar do array
    func removeMeeting(meetingReference: CKRecord.ID){        
        self.meetings.removeAll { 
            $0.recordID == meetingReference
        }
    }
}
