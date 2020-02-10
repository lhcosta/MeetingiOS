//
//  Topic.swift
//  MeetingiOS
//
//  Created by Paulo Ricardo on 11/26/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import Foundation
import CloudKit

/// Struct utilizada na criação de uma pauta, edição desta 
@objc class Topic: NSObject {
    
    //MARK:- Json keys
    enum CodingKeys : CodingKey {
        case record
    }
    
    //MARK: - Properties
    /// Record do tipo Topic
    private(set) var record: CKRecord
    
    /// Topico em si.
    var topicDescription: String {
        set { self.record["description"] = newValue }
        get { return self.record.value(forKey: "description") as? String ?? ""}
    }
    
    /// Referência do autor do Topic.
    var author: CKRecord.Reference? {
        set { self.record["author"] = newValue }
        get { return self.record.value(forKey: "author") as? CKRecord.Reference}
    }
    
    /// Nome do autor para espelhamaneto na TV. (não sendo necessária a requisição no servidor)
    var authorName: String? {
        set { self.record["authorName"] = newValue }
        get { return self.record.value(forKey: "authorName") as? String }
    }
    
    /// Se já foi discutida ou não durante a reunião
    /// Será usada para filtrar as pautas não discutidas e discutidas para a visualização do autor delas.
    var discussed: Bool {
        set { self.record["discussed"] = newValue }
        get { return self.record.value(forKey: "discussed") as? Bool ?? false }
    }
    
    
    /// O Porquê do Topic ter sido feito pelo author
    var topicPorque: String! {
        set { 
            if newValue != NSLocalizedString("Not specified.", comment: "") && !newValue.isEmpty {
                self.record["topicPorque"] = newValue
            }
        }
        
        get { return self.record.value(forKey: "topicPorque") as? String ?? ""}
    }
    
    
    /// Conclusões enviadas pelos funcionários/gerente durante a reunião (quando já discutida?)
    var conclusions: [String] {
        set { self.record["conclusions"] = newValue }
        get { return self.record.value(forKey: "conclusions") as? [String] ?? []}
    }
    
    /// Tempo final levado para a discussão da pauta
    /// Este valor é armazenado automaticamente pelo sistema ao término da reunião.
    var duration: Date? {
        set { self.record["duration"] = newValue }
        get { return self.record.value(forKey: "duration") as? Date}
    }
    
    /// Atributo que decide se o tópico vai ou não para a Meeting, setado peli gerente. (criador da Meeting)
    var selectedForMeeting: Bool {
        set { self.record["selectedForReunion"] = newValue }
        get { return self.record.value(forKey: "selectedForReunion") as? Bool ?? false}
    }
    
    
    //MARK: - Initializer
    init(record: CKRecord) {
        self.record = record
    }

    //MARK: - Methods
    /// Adicionar/editar a pauta do Topic
    /// - Parameter description: Pauta em si.
    func editDescription(_ description: String) {
        self.topicDescription = description
        self.record["description"] = self.topicDescription
    }
    
    
    /// Adicionar conclusão nas pautas discutidas.
    /// - Parameter conclusion: Conclusão da pauta.
    func sendConclusion(_ conclusion: String) {
        
        self.conclusions.append(conclusion)
        self.record["conclusions"] = self.conclusions
    }
    
    /// Guardar o tempo final da pauta quando esta é encerrada na reunião.
    /// - Parameter duration: Tempo em Date (dia/mês/ano vazios).
    func setDuration(duration: Date) {
        self.duration = duration
        self.record["duration"] = self.duration
    }
}

extension Topic : Encodable {
    
    //MARK:- Encoder
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        let recordData = try NSKeyedArchiver.archivedData(withRootObject: record, requiringSecureCoding: true)
        
        try container.encode(recordData, forKey: .record)
    }
}
