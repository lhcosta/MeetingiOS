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
    @IBOutlet var tableViewTopics: UITableView!
    
    @IBOutlet var mirrorButton: UIButton!
    
    /// Array que com os Topics que será exibido na Table View
    var topics: [Topic] = []
    
    /// UserDefaults para pegar a referência do ID do author (usuário).
    let defaults = UserDefaults.standard
    
    /// Meeting criada pelo usuário.
    var currMeeting: Meeting!
    
    /// Booleano identificando se o usuário foi quem criou a reunião
    var usrIsManager = false
    
    /// Títulos das sections da tableView.
    let headerTitles = ["Topics added for Meeting", "Topics to be added"]
    
    @IBOutlet var searchBar: UISearchBar!
    
    var bgButtonImg: String!
    
    var indexPath: IndexPath!
    
    var searchedTopics: [Topic] = []
    
    var isSearching = false
    
    var topicToBeEditedOnSearch: String!
    
    var multipeer : MeetingBrowserPeer?
    
    var meetingTeste : Meeting?
    
    
    /// currMeeting será substituído pela Meeting criada.
    override func viewDidLoad() {
        super.viewDidLoad()
            
        
        //SO TESTE 
        self.multipeer = MeetingBrowserPeer()
        
        CloudManager.shared.fetchRecords(recordIDs: [CKRecord.ID(recordName: "431476BA-2555-4205-A500-282A7C9CC3A1")], desiredKeys: nil) { (record, error) in
            if let record = record?.values.first {
                self.meetingTeste = Meeting(record: record)
            }
        }
        
        
        tableViewTopics.delegate = self
        tableViewTopics.dataSource = self
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.returnKeyType = .done
        
        self.navigationItem.title = "Meeting"
        self.navigationItem.setRightBarButton(UIBarButtonItem(title: "edit", style: .plain, target: nil, action: nil), animated: true)
        
        topics.append(Topic(record: CKRecord(recordType: "Topic")))
        
        // MARK: Simulando
        let meetingRecord = CKRecord(recordType: "Meeting")
        currMeeting = Meeting(record: meetingRecord)
        /// Simulamos que a meeting selecionada foi criada pelo usuário.
        currMeeting.manager = CKRecord.Reference(recordID: CKRecord.ID(recordName: defaults.string(forKey: "recordName") ?? ""), action: .deleteSelf)
        
        /// Verificamos se a meeting selecionada foi criada pelo usuário
        if CKRecord.ID(recordName: defaults.string(forKey: "recordName") ?? "") == currMeeting.manager?.recordID {
            usrIsManager = true
        }
        
        if usrIsManager {
            mirrorButton.isHidden = false
            self.bgButtonImg = "checkmark.square.fill"
        } else {
            mirrorButton.isHidden = true
            self.bgButtonImg = "square."
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
        
        self.indexPath = IndexPath(row: 0, section: 0)
        tableViewTopics.scrollToRow(at: self.indexPath, at: .none, animated: true)
        
        if let newTopicCell = tableViewTopics.cellForRow(at: self.indexPath) as? UnfinishedTopicsTableViewCell {
            if self.indexPath.section != 0 {
                topics.append(Topic(record: CKRecord(recordType: "Topic")))
                tableViewTopics.reloadData()
            }
            newTopicCell.checkButton.setBackgroundImage(UIImage(systemName: self.bgButtonImg), for: .normal)
            newTopicCell.topicTextField.becomeFirstResponder()
        }
    }
    

    
    @IBAction func selectTopicButton(_ sender: Any) {
       
        guard let button = sender as? UIButton else { return }
        guard let cell = button.superview?.superview as? UnfinishedTopicsTableViewCell else { return }
        let indexPath = tableViewTopics.indexPath(for: cell)
        
        if topics[indexPath!.row].discussed {
            button.setBackgroundImage(UIImage(systemName: "square"), for: .normal)
            topics[indexPath!.row].discussed = false
        } else {
            button.setBackgroundImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
            topics[indexPath!.row].discussed = true
        }
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
    
    
//    func createTopic(description: String) -> Topic {
//
//        let topicRecord = CKRecord(recordType: "Topic")
//        let newTopic = Topic(record: topicRecord)
//        newTopic.editDescription(description)
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
////            self.reloadTable()
//        }
//        return newTopic
//    }
    
    
    //MARK:- Multipeer Aqui.
    /// Botão que o gerente apertará para espelhar a Meeting na TV
    /// - Parameter sender: Default.
    @IBAction func espelharMeeting(_ sender: Any) {
        
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(self.meetingTeste)
            self.multipeer?.sendingDataFromPeer(data: data)
        } catch {
            print(error)
        }
    }
    
    
    
    /// Atualiza a table view dos Topics adicionados pelo usuário naquela Meeting específica.
//    func reloadTable() {
//
//        self.topics = []
//        self.topics = []
//        let author = CKRecord.Reference(recordID: CKRecord.ID(recordName: defaults.string(forKey: "recordName")!), action: .none)
//
//        for reference in currMeeting.topics {
//
//            var predicate: NSPredicate
//            if usrIsManager {
//                predicate = NSPredicate(format: "recordID == %@", reference)
//            } else {
//                predicate = NSPredicate(format: "recordID == %@ AND author == %@", reference, author)
//            }
//
//            CloudManager.shared.readRecords(recorType: "Topic", predicate: predicate, desiredKeys: nil, perRecordCompletion: { (record) in
//
//                let topic = Topic.init(record: record)
//                if topic.selectedForMeeting {
//                    self.topics.append(topic)
//                } else {
//                    self.topics.append(topic)
//                }
//            }) {
//                print("Done")
//                DispatchQueue.main.async {
//                    self.tableViewTopics.reloadData()
//                }
//            }
//        }
//    }
}


//MARK: - Table View Delegate/DataSource
extension UnfinishedMeetingViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        topics.append(Topic(record: CKRecord(recordType: "Topic")))
        tableViewTopics.reloadData()
        let newTopicCell = tableViewTopics.cellForRow(at: self.indexPath) as! UnfinishedTopicsTableViewCell
        newTopicCell.checkButton.setBackgroundImage(UIImage(systemName: self.bgButtonImg), for: .normal)
        newTopicCell.topicTextField.becomeFirstResponder()
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isSearching {
            return searchedTopics.count
        }
        return topics.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.frame.height * 0.03
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        return headerView
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! UnfinishedTopicsTableViewCell
        cell.topicTextField.delegate = self
        if isSearching {
            cell.topicTextField.text = searchedTopics[indexPath.section].topicDescription
            if searchedTopics[indexPath.section].selectedForMeeting {
                cell.checkButton.setBackgroundImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
            } else {
                cell.checkButton.setBackgroundImage(UIImage(systemName: "square"), for: .normal)
            }
        } else {
            cell.topicTextField.text = topics[indexPath.section].topicDescription
            if topics[indexPath.section].selectedForMeeting {
                cell.checkButton.setBackgroundImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
            } else {
                cell.checkButton.setBackgroundImage(UIImage(systemName: "square"), for: .normal)
            }
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height * 0.2
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        let cell = tableView.cellForRow(at: indexPath) as! UnfinishedTopicsTableViewCell
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
    
    
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
}


extension UnfinishedMeetingViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if isSearching {
            topicToBeEditedOnSearch = textField.text
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if isSearching {
            
            for i in 0...topics.count-1 {
                if topics[i].topicDescription == topicToBeEditedOnSearch {
                    topics[i].topicDescription = textField.text!
                }
            }
            
            isSearching = false
            searchBar.text = ""
            var temp: [Int] = []
            for i in 0...topics.count-1 {
                if topics[i].topicDescription.isEmpty && i != 0 {
                    temp.append(i)
                }
            }
            for i in temp {
                topics.remove(at: i)
            }
            tableViewTopics.reloadData()
            return true
        } else {
            
            guard let cell = textField.superview?.superview as? UnfinishedTopicsTableViewCell else {
                return false
            }
            let indexPath = tableViewTopics.indexPath(for: cell)
            topics[indexPath!.section].topicDescription = textField.text!
            
            var temp: [Int] = []
            for i in 0...topics.count-1 {
                if topics[i].topicDescription.isEmpty && i != 0 {
                    temp.append(i)
                }
            }
            for i in temp {
                topics.remove(at: i)
            }
            tableViewTopics.reloadData()
            
            if !textField.text!.isEmpty {
                if indexPath!.section == 0 {
                    topics.insert(Topic(record: CKRecord(recordType: "Topic")), at: 0)
                }
                tableViewTopics.reloadData()
                let cell = tableViewTopics.cellForRow(at: IndexPath(row: 0, section: 0)) as! UnfinishedTopicsTableViewCell
                cell.topicTextField.becomeFirstResponder()
            }
            return true
        }
    }
}


extension UnfinishedMeetingViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let sorted = topics.sorted {
            if $0.topicDescription.isEmpty || $1.topicDescription.isEmpty {
                return false
            }
            else if $0.topicDescription.lowercased() == searchBar.text!.lowercased() && $1.topicDescription.lowercased() != searchBar.text!.lowercased() {
                return true
            }
            else if $0.topicDescription.lowercased().hasPrefix(searchBar.text!.lowercased()) && !$1.topicDescription.lowercased().hasPrefix(searchBar.text!.lowercased())  {
                return true
            }
            else if $0.topicDescription.lowercased().hasPrefix(searchBar.text!.lowercased()) && $1.topicDescription.lowercased().hasPrefix(searchBar.text!.lowercased())
                && $0.topicDescription.lowercased().count < $1.topicDescription.lowercased().count  {
                return true
            }
            else if $0.topicDescription.lowercased().contains(searchBar.text!.lowercased()) && !$1.topicDescription.lowercased().contains(searchBar.text!.lowercased()) {
                return true
            }
            else if $0.topicDescription.lowercased().contains(searchBar.text!.lowercased()) && $1.topicDescription.lowercased().contains(searchBar.text!.lowercased())
                && $0.topicDescription.lowercased().count < $1.topicDescription.lowercased().count {
                return true
            }
            return false
        }
        
        searchedTopics = sorted
        searchedTopics.remove(at: 0)
        tableViewTopics.reloadData()
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.isSearching = true
    }
    
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        self.isSearching = false
        tableViewTopics.reloadData()
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
