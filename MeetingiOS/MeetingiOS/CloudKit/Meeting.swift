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
    private(set) var manager : CKRecord
    private(set) var duration : Int64 = 0
    private(set) var employees : [CKRecord.Reference] = []
    private(set) var limitTopic = 3
    private(set) var topic : [CKRecord.Reference] = []
    var finished = false
    var started = false
    var theme : String
    var date : Date
    
    //MARK:- Initializer
    init(date : Date, theme : String, manager : CKRecord){
        self.date = date
        self.theme = theme
        self.manager = manager
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
    mutating func changeNumbersOfTopic(count : Int) {
        self.limitTopic = count
    }
    
}
