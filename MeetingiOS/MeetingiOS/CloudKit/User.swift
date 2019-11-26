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
    private var record: CKRecord
    
    var email: String
    var name: String
    
    // convites vindos da entidade Reunião
    var invites: CKRecord.Reference?
    
    // reuniões vindos da entidade Reunião
    var meetings: CKRecord.Reference?
    
    //MARK: - Initializer
    init(record: CKRecord) {
        self.record = record
        self.email = record.value(forKey: "email") as! String
        self.name = record.value(forKey: "name") as! String
        self.invites = record.value(forKey: "invites") as? CKRecord.Reference
        self.meetings = record.value(forKey: "meetings") as? CKRecord.Reference
    }
}
