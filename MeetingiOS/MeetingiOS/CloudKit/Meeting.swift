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
Classe utilizada para criar um nova reunião, Update de Meeting ou
utilizar como auxílio de manipulação de CKRecord Meeting
- Author: Lucas Costa 
 */

@objc class Meeting: NSObject {
    
    //MARK:- JSON Keys
    enum CodingKeys : String, CodingKey {
        case record, selectedTopics
    }
    
    //MARK:- Properties
    
    ///Record do tipo Meeting
    @objc private(set) var record : CKRecord!
    
    ///Topicos selecionados
    @objc var selected_topics : [Topic] = []
    
    ///Tópicos da reunião
    @objc var topics : [CKRecord.Reference] {
        get {
            self.record.value(forKey: "topics") as? [CKRecord.Reference] ?? []
        }
        
        set {
            self.record.setValue(newValue, forKey: "topics")
        }
    }
        
    ///Gerenciador da reunião
    @objc var manager : CKRecord.Reference? {
        
        set {
            self.record.setValue(newValue, forKey: "manager")
        }
        
        get {
            return self.record.value(forKey: "manager") as? CKRecord.Reference
        }
    }
    
    ///Duração da reunião
    @objc var duration : Int64 {
        
        get {
            self.record.value(forKey: "duration") as? Int64 ?? 0
        }
        
        set {
            self.record.setValue(newValue, forKey: "duration")
        }
    }
    
    ///Funcionários que participaram da reunião
    @objc var employees : [CKRecord.Reference] {
        
        get {
            return self.record.value(forKey: "employees") as? [CKRecord.Reference] ?? []
        }
        
        set {
            self.record.setValue(newValue, forKey: "employees")
        }
    }
    
    ///Limite de tópicos de para cada funcionário
    @objc var limitTopic : Int64 {
        
        get {
            self.record.value(forKey: "limitTopic") as? Int64 ?? 0
        }
        
        set {
            self.record.setValue(newValue, forKey: "limitTopic")
        }
        
    }
    
    ///Reunião finalizada
    @objc var finished : Bool {
        
        get {
            return self.record.value(forKey: "finished") as? Bool ?? false
        }
        
        set {
            self.record.setValue(newValue, forKey: "finished")
        }
        
    }
    
    ///Reunião iniciada
    @objc var started : Bool {
        
        get {
            self.record.value(forKey: "started") as? Bool ?? false
        }
        
        set {
            self.record.setValue(newValue, forKey: "started")
        }
    }
    
    ///Tema da reunião
    @objc var theme : String {
        
        get {
            return self.record.value(forKey: "theme") as? String ?? ""
        }
        
        set {
            self.record.setValue(newValue, forKey: "theme")
        }
    }
    
    ///Data da realização da reunião
    @objc var date : Date? {
        
        get {
            return self.record.value(forKey: "date") as? Date
        }
        
        set {
            self.record.setValue(newValue, forKey: "date")
        }
    }
   
    ///Cor da Reunião
    @objc var color: String? {
        get {
            return self.record.value(forKey: "color") as? String
        }
        
        set {
            self.record.setValue(newValue, forKey: "color")
        }
    }
    
    //MARK: - Initializer
    @objc init(record : CKRecord) {
        self.record = record
    }
    
    //MARK:- Methods
    
    /**
     Adicionando novos funcionários à reunião
    - parameters: 
        - employee: Novo funcionário 
    */
    @objc func addingNewEmployee(_ employee : CKRecord.Reference) {
        self.employees.append(employee)
        self.record.setValue(employees, forKey: "employees")
    }
    
    /**
     Remover funcionários da reunião
    - parameters: 
        - index : Indice do funcionário
    */
    @objc func removingEmployee(index : Int) {
        self.employees.remove(at: index)
        self.record.setValue(employees, forKey: "employees")
    }
    
    /**
     Adicionando novas pautas
     - Parameter topic: Novo tópico
     */
    @objc func addingNewTopic(_ topic : CKRecord.Reference) {
        self.topics.append(topic)
        self.record.setValue(topics, forKey: "topics")
    }
    
    /**
     Filtragem das pautas de acordo com o author
     - Parameter user: Usuário
     - Returns:
            - topics : Tópicos pertencentes ao usuário ou todos caso seja o gerenciador da reunião
        
     */
    @objc func filteringTopics(user : CKRecord) -> [CKRecord.Reference] {
                
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
    
    /// Description: Este método faz a atualização da cor da Reunião
    /// - Parameter hexColor: hexColor referece ao numero da cor selecionada,
    /// cada cor tem seu hexadecimal referente no array de cores
    @objc func editColor(hexColor: String){
        self.color = hexColor
        self.record.setValue(color, forKey: "color")
    }
}

//MARK:- Encodable
extension Meeting : Encodable {
    
    func encode(to encoder: Encoder) throws {
     
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let record = self.record {
            
            let recordData = try NSKeyedArchiver.archivedData(withRootObject: record, requiringSecureCoding: true)
            
            try container.encode(recordData, forKey: .record)  
            try container.encode(self.selected_topics.self, forKey: .selectedTopics)
        }
    }
}
