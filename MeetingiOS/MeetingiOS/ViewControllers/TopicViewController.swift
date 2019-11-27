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

    @IBOutlet var descriptionField: UITextField!
    @IBOutlet var tableViewTopics: UITableView!
    
    var topics: [Topic] = []
    let defaults = UserDefaults.standard
    var currMeeting: Meeting!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let meetingRecord = CKRecord(recordType: "Meeting")
        currMeeting = Meeting(record: meetingRecord)
        
        
        tableViewTopics.delegate = self
        tableViewTopics.dataSource = self
    }
    
    
    @IBAction func sendButton(_ sender: Any) {
        
        let topicRecord = CKRecord(recordType: "Topic")
        var newTopic = Topic(record: topicRecord)
        newTopic.editDescription(descriptionField.text!)
        newTopic.author = CKRecord.Reference(recordID: CKRecord.ID(recordName: defaults.string(forKey: "recordName")!), action: .none)
        
        currMeeting.addingNewTopic(CKRecord.Reference(recordID: CKRecord.ID(recordName: newTopic.record.recordID.recordName), action: .none))
        
        CloudManager.shared.createRecords(records: [newTopic.record, currMeeting.record], perRecordCompletion: { (record, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }) {
            print("Saved!")
            DispatchQueue.main.async {
                self.tableViewTopics.reloadData()
            }
        }
    }
    
    
    @IBAction func retrieveButton(_ sender: Any) {
        
        self.topics = []
        let author = CKRecord.Reference(recordID: CKRecord.ID(recordName: defaults.string(forKey: "recordName")!), action: .none)
        
        for reference in currMeeting.topics {
            
            let predicate = NSPredicate(format: "recordID == %@ AND author == %@", reference, author)
//            let predicate = NSPredicate(format: "author == %@", author)
            print(reference)
            
            CloudManager.shared.readRecords(recorType: "Topic", predicate: predicate, desiredKeys: nil, perRecordCompletion: { (record) in
                self.topics.append(Topic.init(record: record))
            }) {
                print("Done")
                DispatchQueue.main.async {
                    print(self.topics)
                    self.tableViewTopics.reloadData()
                }
            }
        }
    }
}


extension TopicViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.topics.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TopicsTableCiewCell
        cell.topicLabel.text = topics[indexPath.row].description
        return cell
    }
}
