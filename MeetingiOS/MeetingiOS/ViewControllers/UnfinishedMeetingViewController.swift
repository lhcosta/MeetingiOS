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
    /// Será usada para diferenciar os Topics selecionados pelo gerente (No caso de usrIsManager == true)
    var selectedTopics: [Topic] = []
    
    /// UserDefaults para pegar a referência do ID do author (usuário).
    let defaults = UserDefaults.standard
    
    /// Meeting criada pelo usuário.
    var currMeeting: Meeting!
    
    /// Booleano identificando se o usuário foi quem criou a reunião
    var usrIsManager = false
    
    /// Títulos das sections da tableView.
    let headerTitles = ["Topics added for Meeting", "Topics to be added"]
    
    
    /// currMeeting será substituído pela Meeting criada.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Simulando
        let meetingRecord = CKRecord(recordType: "Meeting")
        currMeeting = Meeting(record: meetingRecord)
        /// Simulamos que a meeting selecionada foi criada pelo usuário.
        currMeeting.manager = CKRecord.Reference(recordID: CKRecord.ID(recordName: defaults.string(forKey: "recordName") ?? ""), action: .deleteSelf)
        
        /// Verificamos se a meeting selecionada
        if CKRecord.ID(recordName: defaults.string(forKey: "recordName") ?? "") == currMeeting.manager?.recordID {
            usrIsManager = true
        }
        
        tableViewTopics.delegate = self
        tableViewTopics.dataSource = self
    }
    
    
    //MARK: - Methods
    /// Botão que envia o Topic para o Cloud, tanto para a table Topic quando para o atributo topics do Meeting.
    /// currMeeting ainda será substiuído pela Meeting criada.
    /// - Parameter sender: default
    @IBAction func createTopicButton(_ sender: Any) {
        
        let topicRecord = CKRecord(recordType: "Topic")
        let newTopic = Topic(record: topicRecord)
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
        self.selectedTopics = []
        let author = CKRecord.Reference(recordID: CKRecord.ID(recordName: defaults.string(forKey: "recordName")!), action: .none)
        
        for reference in currMeeting.topics {
            
            var predicate: NSPredicate
            if usrIsManager {
                predicate = NSPredicate(format: "recordID == %@", reference)
            } else {
                predicate = NSPredicate(format: "recordID == %@ AND author == %@", reference, author)
            }
            
            CloudManager.shared.readRecords(recorType: "Topic", predicate: predicate, desiredKeys: nil, perRecordCompletion: { (record) in
                
                let topic = Topic.init(record: record)
                if topic.selectedForMeeting {
                    self.selectedTopics.append(topic)
                } else {
                    self.topics.append(topic)
                }
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
        if section == 0 {
            return self.selectedTopics.count
        } else {
            return self.topics.count
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if usrIsManager {
            return 2
        }
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerTitles[section]
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! UnfinishedTopicsTableViewCell
        if indexPath.section == 0 {
            cell.topicLabel.text = selectedTopics[indexPath.row].topicDescription
        } else {
            cell.topicLabel.text = topics[indexPath.row].topicDescription
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if usrIsManager {
            if indexPath.section == 0 {
                
                selectedTopics[indexPath.row].selectedForMeeting = false
                CloudManager.shared.updateRecords(records: [selectedTopics[indexPath.row].record], perRecordCompletion: { (record, error) in
                    if let error = error { print(error.localizedDescription) }
                }) { }
                topics.append(selectedTopics.remove(at: indexPath.row))
            } else {
                
                topics[indexPath.row].selectedForMeeting = true
                CloudManager.shared.updateRecords(records: [topics[indexPath.row].record], perRecordCompletion: { (record, error) in
                    if let error = error { print(error.localizedDescription) }
                }) { }
                selectedTopics.append(topics.remove(at: indexPath.row))
            }
            tableView.reloadData()
        }
    }
}
