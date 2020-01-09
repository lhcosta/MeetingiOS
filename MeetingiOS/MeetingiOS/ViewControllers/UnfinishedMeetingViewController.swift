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
    
    /// Nome da imagem de fundo do botão de check dos Topics ("square" ou "checkmark.square.fill")
    var bgButtonImg: String!
    
    /// IndexPath utilizado para iniciar uma cell fora do delegate da tableView
    var indexPath: IndexPath!
    
    /// Quando o usuário está em modo de pesquisa, utilizando a seaarchBar
    var isSearching = false
    
    /// Array temporário criado para armazenar os tópicos quando o usuário está em modo de pesquisa. (Para não desorganizar o array principal)
    var searchedTopics: [Topic] = []
    
    /// String que guardará a descrição do Topic selecionado quando em modo de pesquisa.
    /// Será colocado no lugar do Topic correspondente do Array principal.
    var topicToBeEditedOnSearch: String!
    
    var multipeer : MeetingBrowserPeer?
    
    var meetingTeste : Meeting?
    
    
    /// currMeeting será substituído pela Meeting criada.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.backgroundColor = .white
        
        // SearchBar na NavigationBar
        self.setUpSearchBar(segmentedControlTitles: nil)
        self.navigationItem.searchController?.searchBar.delegate = self
        self.navigationItem.searchController?.searchBar.showsCancelButton = true
        self.navigationItem.searchController?.searchBar.returnKeyType = .done
        
        //SO TESTE 
        self.multipeer = MeetingBrowserPeer()
        
        CloudManager.shared.fetchRecords(recordIDs: [CKRecord.ID(recordName: "431476BA-2555-4205-A500-282A7C9CC3A1")], desiredKeys: nil) { (record, error) in
            if let record = record?.values.first {
                self.meetingTeste = Meeting(record: record)
            }
        }
        
        tableViewTopics.delegate = self
        tableViewTopics.dataSource = self
        
        self.navigationItem.title = "Meeting"
        self.navigationItem.setRightBarButton(UIBarButtonItem(title: "edit", style: .plain, target: nil, action: nil), animated: true)
        
        // Pegar Topics do Cloud.
        var tempIDs: [CKRecord.ID] = []
        for i in currMeeting.topics {
            tempIDs.append(i.recordID)
        }
        CloudManager.shared.fetchRecords(recordIDs: tempIDs, desiredKeys: nil) { (records, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            for i in records! {
                let topic = Topic(record: i.value)
                // Quando o usuário não é quem criou a Meeting só pegaremos os Topics cujo ele é o author
                if !self.usrIsManager {
                    if topic.author == CKRecord.Reference(recordID: CKRecord.ID(recordName: self.defaults.string(forKey: "recordName")!), action: .none) {
                        self.topics.append(topic)
                    }
                } else {
                    // Senão pegamos todos os Topics daquela Meeting.
                    self.topics.append(topic)
                }
                
            }
            let newTopic = self.creatingTopicInstance()
            self.topics.insert(newTopic, at: 0)
            
            DispatchQueue.main.async {
                self.tableViewTopics.reloadData()
            }
        }
        
        // Verificamos se a meeting selecionada foi criada pelo usuário
        if CKRecord.ID(recordName: defaults.string(forKey: "recordName") ?? "") == currMeeting.manager?.recordID {
            usrIsManager = true
        }
        
        // Escondemos os botões de selecionar Topic para a Meeting e o botão de mirror.
        // Conforme o usuário foi quem criou ou não a Meeting.
        if usrIsManager {
            mirrorButton.isHidden = false
            self.bgButtonImg = "checkmark.square.fill"
        } else {
            mirrorButton.isHidden = true
//            self.bgButtonImg = "square."
        }
        
        tableViewTopics.delegate = self
        tableViewTopics.dataSource = self
    }
    
    
    /// Criamos um Topic com os dados do Usuário.
    func creatingTopicInstance() -> Topic {
        
        let record = CKRecord(recordType: "Topic")
        let newTopic = Topic(record: record)
        
        newTopic.author = CKRecord.Reference(recordID: CKRecord.ID(recordName: defaults.string(forKey: "recordName")!), action: .none)
        newTopic.authorName = defaults.string(forKey: "givenName")
        newTopic.discussed = false
        
        if usrIsManager {
            newTopic.selectedForMeeting = true
        } else {
            newTopic.selectedForMeeting = false
        }
        return newTopic
    }
    
    
    /// Botão que cria um novo Topic (__Deprecated__)
    /// - Parameter sender: UIButton
    @IBAction func createNewTopic(_ sender: Any) {
        
        self.indexPath = IndexPath(row: 0, section: 0)
        tableViewTopics.scrollToRow(at: self.indexPath, at: .none, animated: true)
        
        if let newTopicCell = tableViewTopics.cellForRow(at: self.indexPath) as? UnfinishedTopicsTableViewCell {
            if self.indexPath.section != 0 {
                let newTopic = creatingTopicInstance()
                topics.append(newTopic)
                tableViewTopics.reloadData()
            }
            if usrIsManager {
                newTopicCell.checkButton.setBackgroundImage(UIImage(systemName: self.bgButtonImg), for: .normal)
            }
            newTopicCell.topicTextField.becomeFirstResponder()
        }
    }

    
    /// Check mark, só para o gerente, que decide se o Topic atual irá para a Meeting.
    /// - Parameter sender: UIButton
    @IBAction func selectTopicButton(_ sender: Any) {
       
        guard let button = sender as? UIButton else { return }
        guard let cell = button.superview?.superview as? UnfinishedTopicsTableViewCell else { return }
        let indexPath = tableViewTopics.indexPath(for: cell)
        
        if topics[indexPath!.section].discussed {
            button.setBackgroundImage(UIImage(systemName: "square"), for: .normal)
            topics[indexPath!.section].discussed = false
        } else {
            button.setBackgroundImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
            topics[indexPath!.section].discussed = true
        }
    }
    
    
    // MARK: Multipeer Aqui.
    /// Botão que o gerente apertará para espelhar a Meeting na TV
    /// - Parameter sender: UIButton.
    @IBAction func espelharMeeting(_ sender: Any) {
        
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(self.meetingTeste)
            self.multipeer?.sendingDataFromPeer(data: data)
        } catch {
            print(error)
        }
    }
}


//MARK: - Table View Delegate/DataSource
extension UnfinishedMeetingViewController: UITableViewDelegate, UITableViewDataSource {
    
//    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//
//        let newTopic = creatingTopicInstance()
//        topics.append(newTopic)
//        tableViewTopics.reloadData()
//
//        CloudManager.shared.updateRecords(records: [currMeeting.record], perRecordCompletion: { (_, error) in
//            if let error = error {
//                print(error.localizedDescription)
//            }
//        }) { }
//        let newTopicCell = tableViewTopics.cellForRow(at: self.indexPath) as! UnfinishedTopicsTableViewCell
//        newTopicCell.checkButton.setBackgroundImage(UIImage(systemName: self.bgButtonImg), for: .normal)
//        newTopicCell.topicTextField.becomeFirstResponder()
//    }
    

    /// Usamos apenas uma Cell em cada Section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    /// A quantidade de dados será exibida em cada Section e não nas Cells.
    func numberOfSections(in tableView: UITableView) -> Int {
        if isSearching {
            return searchedTopics.count
        }
        return topics.count
    }
    
    
    /// Espaçamento de cada section.
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.frame.height * 0.03
    }
    
    
    /// Setamos o Header da section para .clear
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        return headerView
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! UnfinishedTopicsTableViewCell
        cell.topicTextField.delegate = self
        
        // Se não for gerente, não faz sentido termos o botão de check.
        if !usrIsManager {
            cell.checkButton.isHidden = true
        }
        
        // Verificamos se o usuário está em modo de pesquisa.
        if isSearching {
            // Pegamos os dados da Array do modo de pesquisa.
            cell.topicTextField.text = searchedTopics[indexPath.section].topicDescription
            // Verificamos o estado do Topic para alterar o botão de check (selectedForMeeting true ou false)
            if searchedTopics[indexPath.section].selectedForMeeting {
                cell.checkButton.setBackgroundImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
            } else {
                cell.checkButton.setBackgroundImage(UIImage(systemName: "square"), for: .normal)
            }
        } else {
            // Pegamos os dados da Array principal.
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
}


//MARK: - TextField delegate
// Text Field de cada Topic (editar e criar Tópicos)
extension UnfinishedMeetingViewController: UITextFieldDelegate {
    
    /// Chamado toda vez que clicamos em um textField.
    func textFieldDidBeginEditing(_ textField: UITextField) {
        /// Se estamos em modo de pesquisa, salvamos o valor original do Topic para então subtituí-lo na Array principal.
        if isSearching {
            topicToBeEditedOnSearch = textField.text
        }
    }
    
    
    /// Chamado quando o botão return do teclado é pressionado (quando editando o textField)
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Verificamos se estamos no modo de pesquisa.
        if isSearching {
            
            // Fazemos uma varredura no array de topics principal para procurarmos o topic que foi editado
            // no array de pesquisa (Salvamos o valor original do Topic editado anteriormente)
            for i in 0...topics.count-1 {
                if topics[i].topicDescription == topicToBeEditedOnSearch {
                    // Quando achamos o Topic editado no array principal, substituimos ele pelo textField
                    topics[i].topicDescription = textField.text!
                    // Verificamos se a edição não foi uma exclusão.
                    if topics[i].topicDescription != "" {
                        
                        // Retiramos o Topic alterado do Array de Topics da Meeting.
                        // Como a array de Topic da Meeting são References, não podemos alterar diretamente
                        // o seu Topic.description, por isso excluímos e adicionamos denovo.
                        for ii in 0...currMeeting.topics.count-1 {
                            if currMeeting.topics[ii].recordID == topics[i].record.recordID {
                                currMeeting.topics.remove(at: ii)
                                break
                            }
                        }
                        // Adicionamos o Topic editado.
                        currMeeting.addingNewTopic(CKRecord.Reference(recordID: topics[i].record.recordID, action: .deleteSelf))
                        // Damos Update da Meeting e do Topic no Cloud
                        CloudManager.shared.updateRecords(records: [topics[i].record, currMeeting.record], perRecordCompletion: { (_, error) in
                            if let error = error {
                                print(error.localizedDescription)
                            }
                        }) { }
                    } else {
                        // Quando a edição é uma exclusão, excluímos o Topic da Meeting e do Cloud.
                        for ii in 0...currMeeting.topics.count-1 {
                            if currMeeting.topics[ii].recordID == topics[i].record.recordID {
                                currMeeting.topics.remove(at: ii)
                                break
                            }
                        }
                        CloudManager.shared.updateRecords(records: [currMeeting.record], perRecordCompletion: { (_, error) in
                            if let error = error {
                                print(error.localizedDescription)
                            }
                        }) { }
                        CloudManager.shared.deleteRecords(recordIDs: [topics[i].record.recordID], perRecordCompletion: { (_, error) in
                            if let error = error {
                                print(error.localizedDescription)
                            }
                        }) { }
                    }
                }
            }
            // Quando o usuário aperta Return em modo de pesquisa, saímos desse modo.
            isSearching = false
            self.navigationItem.searchController?.searchBar.text = ""
            
            // Excluímos todos os tópicos que ficaram em branco.
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
            // Quando não estamos no modo de pesquisa, nós alteramos a array de Topics principal diretamente
            // Instanciamos uma tableViewCell a partir da superview do textField utilizado.
            guard let cell = textField.superview?.superview as? UnfinishedTopicsTableViewCell else {
                return false
            }
            let indexPath = tableViewTopics.indexPath(for: cell)
            topics[indexPath!.section].topicDescription = textField.text!
            // Se a edição não resultou em um Topic vazio, adicionamos ele no Cloud.
            if topics[indexPath!.section].topicDescription != "" {
                // Adicionamos o Topic na Meeting.
                currMeeting.addingNewTopic(CKRecord.Reference(recordID: topics[indexPath!.section].record.recordID, action: .deleteSelf))
                // Damos update na Meeting e no Topic criado.
                CloudManager.shared.updateRecords(records: [topics[indexPath!.section].record, currMeeting.record], perRecordCompletion: { (_, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                }) { }
            } else if indexPath?.section != 0 {
                // Quando a edição é uma exclusão, excluímos o Topic da Meeting e do Cloud.
                for ii in 0...currMeeting.topics.count-1 {
                    if currMeeting.topics[ii].recordID == topics[indexPath!.section].record.recordID {
                        currMeeting.topics.remove(at: ii)
                        break
                    }
                }
                CloudManager.shared.updateRecords(records: [currMeeting.record], perRecordCompletion: { (_, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                }) { }
                CloudManager.shared.deleteRecords(recordIDs: [topics[indexPath!.section].record.recordID], perRecordCompletion: { (_, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                }) { }
            }
            
            // Excluímos todos os tópicos que ficaram em branco.
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
            
            // Verificamos se o novo Topic não foi vazio e criamos um novo espaço na tbleView para a criação
            // de outro Topic.
            if !textField.text!.isEmpty {
                // Apenas inserimos um espaço para o novo Topic se ele já não existir.
                // (se a edição foi feita em outra Cell)
                if indexPath!.section == 0 {
                    topics.insert(self.creatingTopicInstance(), at: 0)
                }
                tableViewTopics.reloadData()
                let cell = tableViewTopics.cellForRow(at: IndexPath(row: 0, section: 0)) as! UnfinishedTopicsTableViewCell
                cell.topicTextField.becomeFirstResponder()
            }
            return true
        }
    }
}


//MARK: - SearchBar Delegate
extension UnfinishedMeetingViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // Array sorted com o texto da searchBar.
        // é se o Topic contém, como prefixo, sufixo ou por inteiro, o texto escrito na searchBar.
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
        // Um dos Topics é apenas um espaço em branco para adicionar um novo,
        // esse Topic não é necessário no modo de pesquisa.
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
