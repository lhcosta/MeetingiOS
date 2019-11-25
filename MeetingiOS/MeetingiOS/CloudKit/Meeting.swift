//
//  Meeting.swift
//  MeetingiOS
//
//  Created by Lucas Costa  on 25/11/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import Foundation
import CloudKit

/**
Reunião 
- Author: Lucas Costa 
 */

struct Meeting {
    
    //MARK:- Properties
    var manager : CKRecord.Reference?
    var duration : Int64?
    var employees : [CKRecord.Reference] = []
    var limitTopic : Int64?
    var topic : [CKRecord.Reference] = []
    var finished : Bool
    var started : Bool
    var theme : String
    var date : Date?
    
    //MARK: - Initializer
    init(record : CKRecord) {
        self.manager = record.value(forKey: "manager") as? CKRecord.Reference
        self.duration = record.value(forKey: "duration") as? Int64 ?? 40
        self.employees = record.value(forKey: "employees") as? [CKRecord.Reference] ?? []
        self.limitTopic = record.value(forKey: "limitTopic") as? Int64 ?? 3
        self.finished = record.value(forKey: "finished") as? Bool ?? false
        self.started = record.value(forKey: "started") as? Bool ?? false
        self.date = record.value(forKey: "date") as? Date
        self.theme = record.value(forKey: "theme") as? String ?? ""
    }
        
    //MARK:- Methods
    
    /**
     Adicionando novos funcionários à reunião
    - parameters: 
        - employee: Novo funcionário 
    */
    mutating func addingNewEmployee(_ employee : CKRecord.Reference) {
        self.employees.append(employee)
    }
    
    /**
     Adicionando novas pautas
    - parameters:
        - topic : Novo tópico
    */
    mutating func addingNewTopic(_ topic : CKRecord.Reference) {
        self.employees.append(topic)
    }
    
    /**
     Modificando o limite de pautas
        - parameters: 
            - count : Quantidade de tópicos
     */
    mutating func changeNumbersOfTopic(count : Int64) {
        self.limitTopic = count
    }
    
}
