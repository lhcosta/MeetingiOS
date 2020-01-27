//
//  MyMeetingsViewController.swift
//  MeetingiOS
//
//  Created by Paulo Ricardo on 12/4/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import UIKit
import CloudKit

@objc class MyMeetingsViewController: UIViewController {
    
    //MARK:- Properties
    private var meetings = [[Meeting]]()
    private var meetingsToShow = [Meeting]()
    private let cloud = CloudManager.shared
    private let defaults = UserDefaults.standard
    fileprivate var filtered = [Meeting]()
    fileprivate var filterring = false
    @objc var newMeeting: Meeting?
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = .gray
        
        return refreshControl
    }()
    
    //MARK:- IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
                
        meetings.append([Meeting]())
        meetings.append([Meeting]())
        meetingsToShow = meetings[0]
        
        self.tableView.addSubview(refreshControl)
        self.tableView.keyboardDismissMode = .onDrag
        self.tableView.setTableViewBackgroundGradient()
        
        // MARK: Nav Controller Settings
        self.navigationItem.title = NSLocalizedString("My meetings", comment: "")
        self.navigationItem.hidesBackButton = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "perfil", style: .plain, target: self, action: #selector(goToProfile))
        self.setUpSearchBar(segmentedControlTitles: ["Future meetings", "Past meetings"])
        
        // MARK: Query no CK
        
        guard let _ = defaults.string(forKey: "recordName") else { return }
        
        self.refreshMeetings(predicateFormat: "manager = %@"){
            DispatchQueue.main.async {
                self.meetingsToShow = self.meetings[self.navigationItem.searchController?.searchBar.selectedScopeButtonIndex ?? 0]
                self.tableView.reloadData()
            }
        }
        self.refreshMeetings(predicateFormat: "employees CONTAINS %@"){
            DispatchQueue.main.async {
                self.meetingsToShow = self.meetings[self.navigationItem.searchController?.searchBar.selectedScopeButtonIndex ?? 0]
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesSearchBarWhenScrolling = true
        self.showNewMeeting()
    }
    
    //MARK:- Methods
    /// Método para mostrar adicionar reunião que acabou de ser criada localmente
    private func showNewMeeting(){
        var allMeetings = [Meeting]()
        allMeetings.append(contentsOf: meetings[0])
        allMeetings.append(contentsOf: meetings[1])
        
        if let newMeeting = self.newMeeting {
            let recordIDs = allMeetings.map({$0.record.recordID.recordName})
            
            if !recordIDs.contains(newMeeting.record.recordID.recordName) {
                self.appendMeeting(meeting: newMeeting)
                DispatchQueue.main.async {
                    self.meetingsToShow = self.meetings[self.navigationItem.searchController?.searchBar.selectedScopeButtonIndex ?? 0]
                    self.tableView.reloadData()
                }
            }
            self.newMeeting = nil
        }
    }
    
    /// Método para fazer append a array correto de reuniao valindando se essa reuniao ja esta no array
    /// - Parameter meeting: reuniao a ser adicionado
    private func appendMeeting(meeting: Meeting){
        if let finalDate = meeting.finalDate, finalDate > Date(timeIntervalSinceNow: 0), !meeting.finished {
            self.validateMeeting(arrayIndex: 0, meeting: meeting)
        } else {
            self.validateMeeting(arrayIndex: 1, meeting: meeting)
        }
    }
    
    /// Método utilizado para validar se reuniao esta no array
    /// - Parameters:
    ///   - arrayIndex: 0 ou 1 indicando array de reuniao futura ou passada
    ///   - meeting: reuniao a ser verificada
    private func validateMeeting(arrayIndex: Int, meeting: Meeting){
        let recordIDs = meetings[arrayIndex].map({$0.record.recordID.recordName})
        
        if !recordIDs.contains(meeting.record.recordID.recordName) {
            self.meetings[arrayIndex].append(meeting)
        }
    }
    
    /// Método que faz fetch de todas as reunioes
    /// - Parameters:
    ///   - predicateFormat: formato do predicate a ser realizado
    ///   - completion: completion final
    private func refreshMeetings(predicateFormat: String, completion: @escaping (() -> Void)) {
        Meeting.fetchMeetings(predicateFormat: predicateFormat, perRecordCompletion: { (meeting) in
            self.appendMeeting(meeting: meeting)
        }, finalCompletion: {
            completion()
        })
    }
    
    /// Método para fazer refresh da table view
    /// - Parameter refreshControl: default
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.refreshMeetings(predicateFormat: "employees CONTAINS %@") {
            DispatchQueue.main.async {
                self.meetingsToShow = self.meetings[self.navigationItem.searchController?.searchBar.selectedScopeButtonIndex ?? 0]
                self.tableView.reloadData()
                refreshControl.endRefreshing()
            }
        }
    }
    
    @objc func goToProfile() {
        if isLoggedIn(){
            let storyboard = UIStoryboard(name: "Profile", bundle: nil)
            let nextVC = storyboard.instantiateInitialViewController() as! ProfileViewController
            self.present(nextVC, animated: true, completion: nil)
        } else {
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let nextVC = storyboard.instantiateInitialViewController() as! LoginViewController
            nextVC.goingToProfile = true
            self.present(nextVC, animated: true, completion: nil)
        }
    }
    
    private func isLoggedIn() -> Bool{
        if let _ = defaults.value(forKey: "recordName") as? String {
            return true
        } else {
           return false
        }
    }
    
    //MARK: - IBActions
    
    /// Detalhes da reunião.
    @IBAction func detailsOfMeeting(_ sender : UIButton) {
        self.performSegue(withIdentifier: "MeetingDetails", sender: sender)        
    }
}

//MARK: - Table View Delegate/DataSource
extension MyMeetingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.filterring ? self.filtered.count : self.meetingsToShow.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 18
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MyMeetingsTableViewCell
        
        let meetingsArray = self.filterring ? self.filtered : self.meetingsToShow
        
        cell.meetingName.text = meetingsArray[indexPath.section].theme
        cell.detailsButton.tag = indexPath.section
        
        if let date = meetingsArray[indexPath.section].initialDate{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EE MMM dd yyyy"
            let formattedDate = dateFormatter.string(from: date)
            cell.meetingDate.text = formattedDate
        } else {
           cell.meetingDate.text = ""
        }
        
        cell.contentView.layer.cornerRadius = 5
        var color = UIColor()
        if let colorHex = meetingsArray[indexPath.section].color {
            color = UIColor(hexString: colorHex)
        } else {
            color = UIColor(hexString: "93CCB2")
        }
        cell.contentView.backgroundColor = color
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let meetingsArray = self.filterring ? self.filtered : self.meetingsToShow

        if meetingsArray[indexPath.section].finished {
            performSegue(withIdentifier: "finishedMeeting", sender: self.meetingsToShow[indexPath.section])
        } else {
            performSegue(withIdentifier: "unfinishedMeeting", sender: self.meetingsToShow[indexPath.section])
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "finishedMeeting" {
            
            let viewDestination = segue.destination as! FinishedMeetingViewController
            viewDestination.currMeeting = sender as? Meeting
            
        } else if segue.identifier == "unfinishedMeeting" {
            
            let viewDestination = segue.destination as! UnfinishedMeetingViewController
            viewDestination.currMeeting = sender as? Meeting
            
        } else if segue.identifier == "MeetingDetails" {
            
            var meeting : Meeting!
            guard let button = sender as? UIButton, let navigationController = segue.destination as? UINavigationController else {return}
            
            guard let viewController = navigationController.viewControllers.first as? DetailsTableViewController else {return}
                        
            //Reuniao identifica de acordo com a tag do botão.
            meeting = filterring ? self.filtered[button.tag] : self.meetingsToShow[button.tag]
                
            viewController.meeting = meeting
        }
    }
}

//MARK: - Search Settings
extension MyMeetingsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.meetingsToShow = meetings[searchController.searchBar.selectedScopeButtonIndex]
        
        if let text = searchController.searchBar.text, !text.isEmpty {
            
            self.filtered = self.meetingsToShow.filter({ (meeting) -> Bool in

                return (meeting.theme.lowercased().contains(text.lowercased()) || meeting.managerName?.lowercased().contains(text.lowercased()) ?? false)
            })
            
            self.filterring = true
        } else {
            self.filterring = false
            self.filtered = [Meeting]()
        }
        
        self.tableView.reloadData()
    }
}
