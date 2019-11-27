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
Struct utilizada para criar um nova reunião, Update de Meeting ou
utilizar como auxílio de manipulação de CKRecord Meeting
- Author: Lucas Costa 
 */

struct Meeting {
    
    //MARK:- Properties
    
    ///Record do tipo Meeting
    private(set) var record : CKRecord!
    
    ///Gerenciador da reunião
    var manager : CKRecord.Reference? {
        didSet {
            self.record.setValue(manager, forKey: "manager")
        }
    }
    
    ///Duração da reunião
    var duration : Int64? {
        didSet {
            self.record.setValue(duration, forKey: "duration")
        }
    }
    
    ///Funcionários que participaram da reunião
    var employees : [CKRecord.Reference] {
        didSet {
            self.record.setValue(employees, forKey: "employees")
        }
    }
    
    ///Limite de tópicos de para cada funcionário
    var limitTopic : Int64? {
        didSet {
            self.record.setValue(limitTopic, forKey: "limitTopic")
        }
    }
    
    ///Tópicos da reunião
    private(set) var topics : [CKRecord.Reference]
    
    ///Reunião finalizada
    var finished : Bool {
        didSet {
            self.record.setValue(finished, forKey: "finished")
        }
    }
    
    ///Reunião iniciada
    var started : Bool {
        didSet {
            self.record.setValue(started, forKey: "started")
        }
    }
    
    ///Tema da reunião
    var theme : String {
        didSet {
            self.record.setValue(theme, forKey: "theme")
        }
    }
    
    ///Data da realização da reunião
    var date : Date? {
        didSet {
            self.record.setValue(date, forKey: "date")
        }
    }
    
    //MARK: - Initializer
    init(record : CKRecord) {
   
        self.record = record
        self.manager = record.value(forKey: "manager") as? CKRecord.Reference
        self.duration = record.value(forKey: "duration") as? Int64
        self.employees = record.value(forKey: "employees") as? [CKRecord.Reference] ?? []
        self.limitTopic = record.value(forKey: "limitTopic") as? Int64 ?? 3
        self.finished = record.value(forKey: "finished") as? Bool ?? false
        self.started = record.value(forKey: "started") as? Bool ?? false
        self.date = record.value(forKey: "date") as? Date
        self.theme = record.value(forKey: "theme") as? String ?? ""
        self.topics = record.value(forKey: "topics") as? [CKRecord.Reference] ?? []
    }
        
    //MARK:- Methods
    
    /**
     Adicionando novos funcionários à reunião
    - parameters: 
        - employee: Novo funcionário 
    */
    mutating func addingNewEmployee(_ employee : CKRecord.Reference) {
        self.employees.append(employee)
        self.record.setValue(employees, forKey: "employees")
    }
    
    /**
     Remover funcionários da reunião
    - parameters: 
        - index : Indice do funcionário
    */
    mutating func removingEmployee(index : Int) {
        self.employees.remove(at: index)
        self.record.setValue(employees, forKey: "employees")
    }
    
    /**
     Adicionando novas pautas
     - Parameter topic: Novo tópico
     */
    mutating func addingNewTopic(_ topic : CKRecord.Reference) {
        self.topics.append(topic)
        self.record.setValue(topics, forKey: "topics")
    }
    
    /**
     Filtragem das pautas de acordo com o author
     - Parameter user: Usuário
     - Returns:
            - topics : Tópicos pertencentes ao usuário ou todos caso seja o gerenciador da reunião
        
     */
    func filteringTopics(user : CKRecord) -> [CKRecord.Reference] {
                
        if user.value(forKey: "manager") as? Bool ?? false {
            return self.topics
        }
        
        let topics_owner = self.topics.filter { (topic) -> Bool in
            
            if(topic.value(forKey: "author") as? CKRecord.Reference == user.recordID) {
                return true
            }
            
            return false
        }
        
        return topics_owner
    }
}
