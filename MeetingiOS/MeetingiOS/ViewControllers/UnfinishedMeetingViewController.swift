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
    
    @IBOutlet var mirrorButton: UIButton!
    
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
        
        tableViewTopics.delegate = self
        tableViewTopics.dataSource = self
        
        // MARK: Simulando
        let meetingRecord = CKRecord(recordType: "Meeting")
        currMeeting = Meeting(record: meetingRecord)
        /// Simulamos que a meeting selecionada foi criada pelo usuário.
        currMeeting.manager = CKRecord.Reference(recordID: CKRecord.ID(recordName: defaults.string(forKey: "recordName") ?? ""), action: .deleteSelf)
        
        /// Verificamos se a meeting selecionada
        if CKRecord.ID(recordName: defaults.string(forKey: "recordName") ?? "") == currMeeting.manager?.recordID {
            usrIsManager = true
        }
        
        if usrIsManager {
            mirrorButton.isHidden = false
        } else {
            mirrorButton.isHidden = true
            
        }
        
        tableViewTopics.delegate = self
        tableViewTopics.dataSource = self
    }
    
    
//    func createNewCell() -> UnfinishedTopicsTableViewCell {
//
//        selectedTopics.append(Topic(record: CKRecord(recordType: "Topic")))
//        tableViewTopics.reloadData()
//        let newTopicCell = tableViewTopics.cellForRow(at: IndexPath(row: selectedTopics.count-1, section: 0)) as! UnfinishedTopicsTableViewCell
//        newTopicCell.topicTextField.becomeFirstResponder()
//
//        return newTopicCell
//    }
    
    
    @IBAction func createNewTopic(_ sender: Any) {
        
        selectedTopics.append(Topic(record: CKRecord(recordType: "Topic")))
        tableViewTopics.reloadData()
        let newTopicCell = tableViewTopics.cellForRow(at: IndexPath(row: selectedTopics.count-1, section: 0)) as! UnfinishedTopicsTableViewCell
        newTopicCell.topicTextField.becomeFirstResponder()
    }
    
    
    //MARK: - Methods
    /// Botão que envia o Topic para o Cloud, tanto para a table Topic quando para o atributo topics do Meeting.
    /// currMeeting ainda será substiuído pela Meeting criada.
    /// - Parameter sender: default
    @IBAction func createTopicButton(_ sender: Any) {
        
//        let topicRecord = CKRecord(recordType: "Topic")
//        let newTopic = Topic(record: topicRecord)
//        newTopic.editDescription(descriptionField.text!)
//        newTopic.author = CKRecord.Reference(recordID: CKRecord.ID(recordName: defaults.string(forKey: "recordName")!), action: .none)
//        newTopic.authorName = defaults.string(forKey: "givenName") ?? "Desconhecido"
//
//        currMeeting.addingNewTopic(CKRecord.Reference(recordID: CKRecord.ID(recordName: newTopic.record.recordID.recordName), action: .deleteSelf))
//
//        CloudManager.shared.createRecords(records: [newTopic.record, currMeeting.record], perRecordCompletion: { (record, error) in
//            if let error = error {
//                print(error.localizedDescription)
//                return
//            }
//        }) {
//            print("Saved!")
//            self.reloadTable()
//        }
    }
    
    
    func createTopic(description: String) -> Topic {
        
        let topicRecord = CKRecord(recordType: "Topic")
        let newTopic = Topic(record: topicRecord)
        newTopic.editDescription(description)
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
//            self.reloadTable()
        }
        return newTopic
    }
    
    
    // MARK: Multipeer Aqui.
    /// Botão que o gerente apertará para espelhar a Meeting na TV
    /// - Parameter sender: Default.
    @IBAction func espelharMeeting(_ sender: Any) {
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
//        return 1
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
        cell.topicTextField.delegate = self
        if indexPath.section == 0 {
            cell.topicTextField.text = selectedTopics[indexPath.row].topicDescription
        } else {
            cell.topicTextField.isHidden = true
//            cell.topicLabel.text = topics[indexPath.row].topicDescription
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! UnfinishedTopicsTableViewCell
//        cell.topicTextField.isHidden = false
//        var teste = cell.topicTextField.becomeFirstResponder()
//        var teste = cell.becomeFirstResponder()
//        cell.topicTextField.delegate = self
        
//        if usrIsManager {
//            if indexPath.section == 0 {
//
//                selectedTopics[indexPath.row].selectedForMeeting = false
//                CloudManager.shared.updateRecords(records: [selectedTopics[indexPath.row].record], perRecordCompletion: { (record, error) in
//                    if let error = error { print(error.localizedDescription) }
//                }) { }
//                topics.append(selectedTopics.remove(at: indexPath.row))
//            } else {
//
//                topics[indexPath.row].selectedForMeeting = true
//                CloudManager.shared.updateRecords(records: [topics[indexPath.row].record], perRecordCompletion: { (record, error) in
//                    if let error = error { print(error.localizedDescription) }
//                }) { }
//                selectedTopics.append(topics.remove(at: indexPath.row))
//            }
//            tableView.reloadData()
//        }
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}


extension UnfinishedMeetingViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        guard let cell = textField.superview?.superview as? UnfinishedTopicsTableViewCell else {
            return false
        }
        
        let indexPath = tableViewTopics.indexPath(for: cell)
        selectedTopics[indexPath!.row].topicDescription = textField.text!
        
        
        
        var temp: [Int] = []
        for i in 0...selectedTopics.count-1 {
//            let cell = tableViewTopics.cellForRow(at: IndexPath(row: i, section: 0)) as! UnfinishedTopicsTableViewCell
//            if cell.topicTextField.text!.isEmpty {
//                temp.append(i)
//            }
            if selectedTopics[i].topicDescription.isEmpty {
                temp.append(i)
            }
        }
        for i in temp {
            selectedTopics.remove(at: i)
        }
        tableViewTopics.reloadData()
        
        if !textField.text!.isEmpty {
            selectedTopics.append(Topic(record: CKRecord(recordType: "Topic")))
            tableViewTopics.reloadData()
            let cell = tableViewTopics.cellForRow(at: IndexPath(row: selectedTopics.count-1, section: 0)) as! UnfinishedTopicsTableViewCell
            cell.topicTextField.becomeFirstResponder()
        }
        
        return true
    }
}
