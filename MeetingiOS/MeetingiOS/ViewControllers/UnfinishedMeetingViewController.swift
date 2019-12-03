//
//  TopicViewController.swift
//  MeetingiOS
//
//  Created by Paulo Ricardo on 11/25/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import UIKit
import CloudKit


/// ViewController onde adicionamos os Topics em um Meeting (MeetingViewController ficaria melhor :/).
class UnfinishedMeetingViewController: UIViewController {

    //MARK: - Properties
    @IBOutlet var descriptionField: UITextField!
    @IBOutlet var tableViewTopics: UITableView!
    
    /// Array que com os Topics que será exibido na Table View
    var topics: [Topic] = []
    
    /// UserDefaults para pegar a referência do ID do author (usuário).
    let defaults = UserDefaults.standard
    
    /// Meeting criada pelo usuário.
    var currMeeting: Meeting!
    
    
    /// currMeeting será substituído pela Meeting criada.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let meetingRecord = CKRecord(recordType: "Meeting")
        currMeeting = Meeting(record: meetingRecord)
        
        tableViewTopics.delegate = self
        tableViewTopics.dataSource = self
    }
    
    
    //MARK: - Methods
    /// Botão que envia o Topic para o Cloud, tanto para a table Topic quando para o atributo topics do Meeting.
    /// currMeeting ainda será substiuído pela Meeting criada.
    /// - Parameter sender: default
    @IBAction func createTopicButton(_ sender: Any) {
        
        let topicRecord = CKRecord(recordType: "Topic")
        var newTopic = Topic(record: topicRecord)
        newTopic.editDescription(descriptionField.text!)
        newTopic.author = CKRecord.Reference(recordID: CKRecord.ID(recordName: defaults.string(forKey: "recordName")!), action: .none)
        newTopic.authorName = defaults.string(forKey: "givenName") ?? "Desconhecido"
        
        currMeeting.addingNewTopic(CKRecord.Reference(recordID: CKRecord.ID(recordName: newTopic.record.recordID.recordName), action: .deleteSelf))
        
        CloudManager.shared.createRecords(records: [newTopic.record, currMeeting.record], perRecordCompletion: { (record, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }) {
            print("Saved!")
            self.reloadTable()
        }
    }
    
    
    /// Atualiza a table view dos Topics adicionados pelo usuário naquela Meeting específica.
    func reloadTable() {
        
        self.topics = []
        let author = CKRecord.Reference(recordID: CKRecord.ID(recordName: defaults.string(forKey: "recordName")!), action: .none)
        
        for reference in currMeeting.topics {
            
            let predicate = NSPredicate(format: "recordID == %@ AND author == %@", reference, author)
            
            CloudManager.shared.readRecords(recorType: "Topic", predicate: predicate, desiredKeys: nil, perRecordCompletion: { (record) in
                self.topics.append(Topic.init(record: record))
            }) {
                print("Done")
                DispatchQueue.main.async {
                    self.tableViewTopics.reloadData()
                }
            }
        }
    }
}


//MARK: - Table View Delegate/DataSource
extension UnfinishedMeetingViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.topics.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TopicsTableViewCell
        cell.topicLabel.text = topics[indexPath.row].description
        return cell
    }
}
