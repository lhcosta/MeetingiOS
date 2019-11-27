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
struct Topic {
    
    //MARK: - Properties
    /// Record do tipo Topic
    private(set) var record: CKRecord
    
    /// Topico em si.
    var description: String {
        didSet { self.record["description"] = description }
    }
    
    /// Referência do autor do Topic.
    var author: CKRecord.Reference? {
        didSet { self.record["author"] = author }
    }
    
    /// Nome do autor para espelhamaneto na TV. (não sendo necessária a requisição no servidor)
    var authorName: String {
        didSet { self.record["authorName"] = authorName }
    }
    
    /// Se já foi discutida ou não durante a reunião
    /// Será usada para filtrar as pautas não discutidas e discutidas para a visualização do autor delas.
    var discussed: Bool {
        didSet { self.record["discussed"] = discussed }
    }
    
    /// Conclusões enviadas pelos funcionários/gerente durante a reunião (quando já discutida?)
    var conclusions: [String] {
        didSet { self.record["conclusions"] = conclusions }
    }
    
    /// Tempo final levado para a discussão da pauta
    /// Este valor é armazenado automaticamente pelo sistema ao término da reunião.
    var duration: Date? {
        didSet { self.record["duration"] = duration }
    }
    
    /// Atributo que decide se o tópico vai ou não para a Meeting, setado peli gerente. (criador da Meeting)
    var selectedForReunion: Bool {
        didSet { self.record["selectedForReunion"] = selectedForReunion }
    }
    
    
    //MARK: - Initializer
    init(record: CKRecord) {
        
        self.record = record
        self.description = record["description"] as? String ?? ""
        self.author = record["author"] as? CKRecord.Reference
        self.authorName = record["authorName"] as? String ?? "Desconhecido"
        self.discussed = record["discussed"] as? Bool ?? false
        self.conclusions = record["conclusions"] as? [String] ?? []
        self.duration = record["duration"] as? Date ?? Date()
        self.selectedForReunion = record["selectedForReunion"] as? Bool ?? false
    }
    
    
    //MARK: - Methods
    /// Adicionar/editar a pauta do Topic
    /// - Parameter description: Pauta em si.
    mutating func editDescription(_ description: String) {
        
        self.description = description
        self.record["description"] = self.description
    }
    
    
    /// Adicionar conclusão nas pautas discutidas.
    /// - Parameter conclusion: Conclusão da pauta.
    mutating func sendConclusion(_ conclusion: String) {
        
        self.conclusions.append(conclusion)
        self.record["conclusions"] = self.conclusions
    }
    
    
    /// Guardar o tempo final da pauta quando esta é encerrada na reunião.
    /// - Parameter duration: Tempo em Date (dia/mês/ano vazios).
    mutating func setDuration(duration: Date) {
        self.duration = duration
        self.record["duration"] = self.duration
    }
}
