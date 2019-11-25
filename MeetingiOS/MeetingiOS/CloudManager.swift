//
//  CloudManager.swift
//  MeetingiOS
//
//  Created by Bernardo Nunes on 25/11/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import Foundation
import CloudKit

class CloudManager {
    
    static let shared = CloudManager()
    private let database = CKContainer(identifier: "iCloud.com.QuartetoFantastico.Meeting").publicCloudDatabase
    
    private func setOP(savePolicy: CKModifyRecordsOperation.RecordSavePolicy, perRecordCompletion: @escaping ((CKRecord, Error?) -> Void), finalCompletion: @escaping (() -> Void)) -> CKModifyRecordsOperation {
        let operation = CKModifyRecordsOperation()
        operation.savePolicy = savePolicy
        
        operation.perRecordCompletionBlock = {(record, error) in
            perRecordCompletion(record, error)
        }
        
        operation.completionBlock = {
            finalCompletion()
        }
        
        return operation
    }
        
    func createRecords(records: [CKRecord], perRecordCompletion: @escaping ((CKRecord, Error?) -> Void), finalCompletion: @escaping (() -> Void)){
        let saveOp = setOP(savePolicy: .allKeys, perRecordCompletion: perRecordCompletion, finalCompletion: finalCompletion)
        saveOp.recordsToSave = records

        database.add(saveOp)
    }
    
    func updateRecords(records: [CKRecord], perRecordCompletion: @escaping ((CKRecord, Error?) -> Void), finalCompletion: @escaping (() -> Void)){
        let updateOp = setOP(savePolicy: .changedKeys, perRecordCompletion: perRecordCompletion, finalCompletion: finalCompletion)
        updateOp.recordsToSave = records
        
        database.add(updateOp)
    }
    
    func deleteRecords(recordIDs: [CKRecord.ID], perRecordCompletion: @escaping ((CKRecord, Error?) -> Void), finalCompletion: @escaping (() -> Void)){
        let deleteOp = setOP(savePolicy: .changedKeys, perRecordCompletion: perRecordCompletion, finalCompletion: finalCompletion)
        deleteOp.recordIDsToDelete = recordIDs
        
        database.add(deleteOp)
    }
    
    func readRecords(recorType: String, predicate: NSPredicate, perRecordCompletion: @escaping ((CKRecord) -> Void), finalCompletion: @escaping (() -> Void)){
        
        let query = CKQuery(recordType: recorType, predicate: predicate)
        let queryOp = CKQueryOperation(query: query)
        
        queryOp.recordFetchedBlock = { (record) in
            perRecordCompletion(record)
        }
        
        queryOp.completionBlock = {
            finalCompletion()
        }
        
        database.add(queryOp)
    }
}
