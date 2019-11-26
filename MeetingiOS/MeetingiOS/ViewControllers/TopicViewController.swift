//
//  TopicViewController.swift
//  MeetingiOS
//
//  Created by Paulo Ricardo on 11/25/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import UIKit
import CloudKit

class TopicViewController: UIViewController {

    let manager = CloudManager()
    @IBOutlet var descriptionField: UITextField!
    @IBOutlet var tableViewTopics: UITableView!
    var newTopic: CKRecord!
    var topics: [Topic] = []
    let email: String = ""
    
//    var id: CKRecord.ID
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewTopics.delegate = self
        tableViewTopics.dataSource = self
    }
    
    
    @IBAction func sendButton(_ sender: Any) {
        
        newTopic = CKRecord(recordType: "Topic")
        newTopic["description"] = descriptionField.text!
//        newTopic["author"] = "Eu"
//        newTopic["conclusions"] = "Some work here."
        
        let myContainer = CKContainer.default()
        let database = myContainer.publicCloudDatabase
        
        database.save(newTopic) { (_, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }
        
        let name = ""
        let predicate = NSPredicate(format: "name == %@", name)
        
        let query = CKQuery(recordType: "Topic", predicate: predicate)
        
        database.perform(query, inZoneWith: CKRecordZone.default().zoneID) { (results, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            
        }
    }
    
    
    @IBAction func retrieveButton(_ sender: Any) {
        
        let predicate = NSPredicate(format: "recordID == %@", self.id)
        let query = CKQuery(recordType: "Topic", predicate: predicate)
        
        let container = CKContainer.default()
        let database = container.publicCloudDatabase
        
        database.perform(query, inZoneWith: CKRecordZone.default().zoneID) { (results, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let results = results else { return }
            self.topics = results.map(Topic.init)
        }
    }
    
    
    func retrieveID(database: CKDatabase) {
        
        let predicate = NSPredicate(format: "email == %@", email)
        let query = CKQuery(recordType: "User", predicate: predicate)
        
        database.perform(query, inZoneWith: CKRecordZone.default().zoneID) { (result, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let result = result else { return }
            
            let topicResults = result.map(User.init)
//            self.id = topicResults[0].id
        }
    }
}


extension TopicViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.topics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
}
