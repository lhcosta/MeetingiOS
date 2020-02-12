//
//  TopicViewController.swift
//  MeetingiOS
//
//  Created by Paulo Ricardo on 11/25/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import UIKit
import CloudKit
import MultipeerConnectivity

/// ViewController onde adicionamos os Topics em um Meeting (MeetingViewController ficaria melhor :/).
class UnfinishedMeetingViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet var tableViewTopics: UITableView!
    @IBOutlet weak var buttonItem: UIBarButtonItem!
    
    
    //MARK: - Properties
    /// Array que com os Topics que será exibido na Table View
    var topics: [Topic] = []
    
    /// UserDefaults para pegar a referência do ID do author (usuário).
    let defaults = UserDefaults.standard
    
    /// Meeting criada pelo usuário.
    var currMeeting: Meeting!
    
    /// Booleano identificando se o usuário foi quem criou a reunião
    var usrIsManager = false
    
    /// Nome da imagem de fundo do botão de check dos Topics ("square" ou "checkmark.square.fill")
    //    var bgButtonImg: String!
    
    /// IndexPath utilizado para iniciar uma cell fora do delegate da tableView
    var indexPath: IndexPath!
    
    /// Quando o usuário está em modo de pesquisa, utilizando a seaarchBar
    var isSearching = false
    
    /// Array temporário criado para armazenar os tópicos quando o usuário está em modo de pesquisa. (Para não desorganizar o array principal)
    var searchedTopics: [Topic] = []
    
    /// String que guardará a descrição do Topic selecionado quando em modo de pesquisa.
    /// Será colocado no lugar do Topic correspondente do Array principal.
    var topicToBeEditedOnSearch: String!
    
    var selectedTopicForInfo: Topic?
    
    /// Loading inicial da view.
    var loadingView : UIView!
    
    var activeField: UITextField?
    
    private var buttonToolbar : UIButton!
    
    /// currMeeting será substituído pela Meeting criada.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadingView = self.addInitialLoadingView(frame: self.view.frame)
        
        // SearchBar na NavigationBar
        self.setUpSearchBar(segmentedControlTitles: nil)
        self.navigationItem.searchController?.searchBar.delegate = self
        self.navigationItem.searchController?.searchBar.returnKeyType = .done
        
        tableViewTopics.delegate = self
        tableViewTopics.dataSource = self
        
        self.navigationItem.title = currMeeting.theme
        
        /// Dispara as funções de manipulação do teclado
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.addSubview(loadingView)
        
        CloudManager.shared.fetchRecords(recordIDs: [currMeeting.record.recordID], desiredKeys: nil) { (record, error) in
            if let record = record?.values.first {
                self.currMeeting = Meeting(record: record)
            }
        
            // Pegar Topics do Cloud.
            var tempIDs: [CKRecord.ID] = []
            for i in self.currMeeting.topics {
                tempIDs.append(i.recordID)
            }
            self.topics = []
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
                    UIView.animate(withDuration: 0.5, animations: {
                        self.loadingView.alpha = 0
                    }) { (_) in
                        self.loadingView.removeFromSuperview()
                    }

                }
            }
            
            // Verificamos se a meeting selecionada foi criada pelo usuário
            if CKRecord.ID(recordName: self.defaults.string(forKey: "recordName") ?? "") == self.currMeeting.manager?.recordID {
                self.usrIsManager = true
            }
            
            // Escondemos os botões de selecionar Topic para a Meeting e o botão de mirror.
            // Conforme o usuário foi quem criou ou não a Meeting.
            // Adicionando share button, quando não for o manager.
            DispatchQueue.main.async {
                if !self.usrIsManager {
                    let shareButton = UIButton()
                    shareButton.addTarget(self, action: #selector(self.shareTopicsToMeeting), for: .touchUpInside)
                    shareButton.setImage(UIImage(named: "shareButton"), for: .normal)
                    self.buttonItem.customView = shareButton
                    
                    NSLayoutConstraint.activate([
                        shareButton.widthAnchor.constraint(equalToConstant: 70),
                        shareButton.heightAnchor.constraint(equalToConstant: 40)
                    ])
                }
                
                self.tableViewTopics.delegate = self
                self.tableViewTopics.dataSource = self
            }
        }
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
    
    
//    @objc func createNewTopic() {
//
//        self.indexPath = IndexPath(row: 0, section: 0)
//        tableViewTopics.scrollToRow(at: self.indexPath, at: .none, animated: true)
//
//        if let newTopicCell = tableViewTopics.cellForRow(at: self.indexPath) as? UnfinishedTopicsTableViewCell {
//            if self.indexPath.section != 0 {
//                let newTopic = creatingTopicInstance()
//                topics.append(newTopic)
//                tableViewTopics.reloadData()
//            }
//            if usrIsManager {
//                newTopicCell.checkButton.setBackgroundImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
//            }
//            newTopicCell.topicTextField.becomeFirstResponder()
//        }
//    }
    
    
    /// Check mark, só para o gerente, que decide se o Topic atual irá para a Meeting.
    /// - Parameter sender: UIButton
    @IBAction func selectTopicButton(_ sender: Any) {
        
        guard let button = sender as? UIButton else { return }
        
        guard let cell = button.superview?.superview?.superview as? UnfinishedTopicsTableViewCell else { return }
        
        let indexPath = tableViewTopics.indexPath(for: cell)
        
        if topics[indexPath!.section].selectedForMeeting {
            button.setBackgroundImage(UIImage(systemName: "square"), for: .normal)
            topics[indexPath!.section].selectedForMeeting = false
        } else {
            button.setBackgroundImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
            topics[indexPath!.section].selectedForMeeting = true
        }
        
        // Atualizamos o Cloud da selectedForMeeting.
        CloudManager.shared.updateRecords(records: [topics[indexPath!.section].record], perRecordCompletion: { (_, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }) { }
        
        
    }
    
    
    @IBAction func topicInfoButton(_ sender: Any) {
        
        guard let button = sender as? UIButton else { return }
        
        if let cell = button.superview?.superview?.superview as? UnfinishedTopicsTableViewCell {
            let indexPath = tableViewTopics.indexPath(for: cell)
            
            if isSearching {
                self.selectedTopicForInfo = searchedTopics[indexPath?.section ?? 0]
            } else {
                self.selectedTopicForInfo = topics[indexPath?.section ?? 0]
            }
            
            performSegue(withIdentifier: "conclusionUnfinished", sender: self)
        }
    }
    
    
    // FIXME:- Do
    // MARK:- Multipeer Aqui.
    /// Botão que o gerente apertará para espelhar a Meeting na TV
    /// - Parameter sender: UIButton.
    @IBAction func espelharMeeting(_ sender: Any) {
        
        currMeeting.selected_topics = []
        for idx in 1..<topics.count {
            
            if topics[idx].selectedForMeeting {
                
                currMeeting.selected_topics.append(topics[idx])
                
            }
        }
        
        self.currMeeting.started = true
        
        CloudManager.shared.updateRecords(records: [self.currMeeting.record], perRecordCompletion: { (record, error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }) {}
        
        showTvTableView()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "SelectTV" {
            
            guard let viewController = segue.destination as? SelectionTVsViewController else {return}
            viewController.meeting = self.currMeeting
            
        } else if segue.identifier == "conclusionUnfinished" {
            if let navigation = segue.destination as? UINavigationController, let conclusionVC = navigation.viewControllers.first as? ConclusionsViewController {
                
                conclusionVC.fromUnfinishedMeeting = true
                conclusionVC.topicToPresentConclusions = self.selectedTopicForInfo
                conclusionVC.meetingDidBegin = self.currMeeting.started
                self.view.setNeedsDisplay()
            }
            
        }
    }
    
    
    /// Eleva a tela para o teclado aparecer
    @objc func keyboardWillShow(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        self.tableViewTopics.isScrollEnabled = true
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height*1.2, right: 0.0)

        self.tableViewTopics.contentInset = contentInsets
        self.tableViewTopics.scrollIndicatorInsets = contentInsets

        var aRect: CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = self.activeField {
            if (!aRect.contains(activeField.frame.origin)){
                self.tableViewTopics.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: -keyboardSize!.height*1.2, right: 0.0)
        self.tableViewTopics.contentInset = contentInsets
        self.tableViewTopics.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
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
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.layer.masksToBounds = true;
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! UnfinishedTopicsTableViewCell
        let font = UIFont(name: "SF Pro Text Regular", size: (tableView.frame.size.height * 0.2) * 0.2)
        
        cell.topicTextField.delegate = self
        cell.buttonHeight.constant = (tableView.frame.size.height * 0.2) * 0.4
        cell.buttonWidth.constant = (tableView.frame.size.height * 0.2) * 0.4
        cell.buttonLeftSpace.constant = (tableView.frame.size.height * 0.2) * 0.2
        cell.textFieldLeft.priority = UILayoutPriority(1000)
        cell.checkButton.isHidden = false
        cell.textFieldLeft.constant = (tableView.frame.size.height * 0.2) * 0.12
        cell.textFieldRight.constant = (tableView.frame.size.height * 0.2) * 0.2
        cell.textFieldHeight.constant = (tableView.frame.size.height * 0.2) * 0.2
        cell.textLabel?.font = font
        
        // Se não for gerente, não faz sentido termos o botão de check.
        if !usrIsManager {
            cell.checkButton.isHidden = true
            cell.textFieldSecondLeft.constant = (tableView.frame.size.height * 0.2) * 0.2
            cell.textFieldLeft.priority = UILayoutPriority(998)
        } /*else {
         
         }*/
        cell.topicTextField.placeholder = NSLocalizedString("Topic's name", comment: "")
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
            if indexPath.section == 0 {
                cell.buttonInfo.isHidden = false
            }
        } else {
            // Pegamos os dados da Array principal.
            cell.topicTextField.text = topics[indexPath.section].topicDescription
            if cell.topicTextField.text!.isEmpty {
                cell.checkButton.isHidden = true
                cell.textFieldSecondLeft.constant = (tableView.frame.size.height * 0.2) * 0.2
                cell.textFieldLeft.priority = UILayoutPriority(998)
            }
            if topics[indexPath.section].selectedForMeeting {
                cell.checkButton.setBackgroundImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
            } else {
                cell.checkButton.setBackgroundImage(UIImage(systemName: "square"), for: .normal)
            }
            
            if indexPath.section == 0 {
                cell.buttonInfo.isHidden = true
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
        
        guard let cell = textField.superview?.superview?.superview as? UnfinishedTopicsTableViewCell else { return }
//        if tableViewTopics.indexPath(for: cell)?.section != 0 {
//            cell.buttonInfo.alpha = 1
//            cell.buttonInfo.isEnabled = true
//        }
//        tableViewTopics.isScrollEnabled = false
        self.activeField = textField
        self.indexPath = tableViewTopics.indexPath(for: cell)
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
                        
                        if usrIsManager {
                            /// Damos Update da Meeting e do Topic no Cloud caso o usuário seja o Gerente
                            CloudManager.shared.updateRecords(records: [topics[i].record, currMeeting.record], perRecordCompletion: { (_, error) in
                                if let error = error {
                                    print(error.localizedDescription)
                                }
                            }) { }
                        } else {
                            // Damos Update domente do Topic no Cloud para o caso do usuário ser um Funcionário
                            CloudManager.shared.updateRecords(records: [topics[i].record], perRecordCompletion: { (_, error) in
                                if let error = error {
                                    print(error.localizedDescription)
                                }
                            }) { }
                        }
                        
                    } else {
                        // Quando a edição é uma exclusão, excluímos o Topic da Meeting e do Cloud.
                        for ii in 0...currMeeting.topics.count-1 {
                            if currMeeting.topics[ii].recordID == topics[i].record.recordID {
                                currMeeting.topics.remove(at: ii)
                                break
                            }
                        }
                        if usrIsManager {
                            CloudManager.shared.updateRecords(records: [currMeeting.record], perRecordCompletion: { (_, error) in
                                if let error = error {
                                    print(error.localizedDescription)
                                }
                            }) { }
                        }
                        
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
            guard let cell = textField.superview?.superview?.superview as? UnfinishedTopicsTableViewCell else {
                return false
            }
            let indexPath = tableViewTopics.indexPath(for: cell) ?? self.indexPath!
            topics[indexPath.section].topicDescription = textField.text!
            // Se a edição não resultou em um Topic vazio, adicionamos ele no Cloud.
            if topics[indexPath.section].topicDescription != "" {
                // Adicionamos o Topic na Meeting.
                currMeeting.addingNewTopic(CKRecord.Reference(recordID: topics[indexPath.section].record.recordID, action: .deleteSelf))
                // Damos update na Meeting e no Topic criado.
                CloudManager.shared.updateRecords(records: [topics[indexPath.section].record, currMeeting.record], perRecordCompletion: { (_, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                }) { }
            } else if indexPath.section != 0 {
                // Quando a edição é uma exclusão, excluímos o Topic da Meeting e do Cloud.
                for ii in 0...currMeeting.topics.count-1 {
                    if currMeeting.topics[ii].recordID == topics[indexPath.section].record.recordID {
                        currMeeting.topics.remove(at: ii)
                        break
                    }
                }
                if usrIsManager {
                    CloudManager.shared.updateRecords(records: [currMeeting.record], perRecordCompletion: { (_, error) in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                    }) { }
                }
                
                CloudManager.shared.deleteRecords(recordIDs: [topics[indexPath.section].record.recordID], perRecordCompletion: { (_, error) in
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
            
            // Verificamos se o novo Topic não foi vazio e criamos um novo espaço na tableView para a criação
            // de outro Topic.
            if !textField.text!.isEmpty {
                // Apenas inserimos um espaço para o novo Topic se ele já não existir.
                // (se a edição foi feita em outra Cell)
                if indexPath.section == 0 {
                    topics.insert(self.creatingTopicInstance(), at: 0)
                    tableViewTopics.reloadData()
                    let cell = tableViewTopics.cellForRow(at: IndexPath(row: 0, section: 0)) as! UnfinishedTopicsTableViewCell
                    cell.topicTextField.becomeFirstResponder()
                }
            }
            tableViewTopics.reloadData()
            
            return true
        }
    }
}


//MARK: - SearchBar Delegate
extension UnfinishedMeetingViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // Array sorted com o texto da searchBar.
        // é se o Topic contém, como prefixo, sufixo ou por inteiro, o texto escrito na searchBar.
        var filteringTopics = [Topic]()
        
        self.topics.forEach {
            if $0.topicDescription.lowercased().contains(searchText.lowercased()) {
                filteringTopics.append($0)
            }
        }
        
        searchedTopics = filteringTopics.sorted(by: { (lhs, rhs) -> Bool in
            lhs.topicDescription < rhs.topicDescription
        })
        
        // Um dos Topics é apenas um espaço em branco para adicionar um novo,
        // esse Topic não é necessário no modo de pesquisa.
       // searchedTopics.remove(at: 0)
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

//MARK:- Show TVs to Mirror
extension UnfinishedMeetingViewController : UIGestureRecognizerDelegate {
    
    /// Apresentar TVs disponiveis para espelhar.
    func showTvTableView() {
        self.performSegue(withIdentifier: "SelectTV", sender: nil)
    }
}

//MARK:- Enviar tópicos para a reunião quando não for manager
private extension UnfinishedMeetingViewController {
    
    /// Enviando tópicos criados para a reunião.
    @objc func shareTopicsToMeeting() {
        
        let loadingAlert = UIAlertController(title: nil, message: "Loading", preferredStyle: .alert)
        loadingAlert.addUIActivityIndicatorView()
        
        self.present(loadingAlert, animated: true)
        
        // Damos Update da Meeting e do Topic no Cloud
        CloudManager.shared.updateRecords(records: [currMeeting.record], perRecordCompletion: { (_, error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }) {
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true, completion: {
                    self.navigationController?.popViewController(animated: true)
                })
            }
        }
    }
    
    
}
