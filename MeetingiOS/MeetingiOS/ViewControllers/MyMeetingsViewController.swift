//
//  MyMeetingsViewController.swift
//  MeetingiOS
//
//  Created by Paulo Ricardo on 12/4/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import UIKit
import CloudKit

class MyMeetingsViewController: UIViewController {
    
    //MARK:- Properties
    private var meetings = [[Meeting]]()
    private var meetingsToShow = [Meeting]()
    private let cloud = CloudManager.shared
    private let defaults = UserDefaults.standard
    fileprivate var filtered = [Meeting]()
    fileprivate var filterring = false
    
    //MARK:- IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        meetings.append([Meeting]())
        meetings.append([Meeting]())
        meetingsToShow = meetings[0]
        
        // MARK: Nav Controller Settings
        self.navigationItem.title = "My Meetings"
        self.navigationItem.hidesBackButton = true
        self.setUpSearchBar(segmentedControlTitles: ["Future meetings", "Past meetings"])
        
        // MARK: Query no CK
        guard let recordName = defaults.string(forKey: "recordName") else { return }
        let userReference = CKRecord.Reference(recordID: CKRecord.ID(recordName: recordName), action: .none)
        let predicateManager = NSPredicate(format:"manager = %@", userReference)
        let predicateEmployee = NSPredicate(format:"employees CONTAINS %@", userReference)
        
        var notMyMeetings: [Meeting] = []
        
        //Realiza o fetch das reunioes que nao sao suas e atribui o nome do manager
        cloud.readRecords(recorType: "Meeting", predicate: predicateEmployee, desiredKeys: nil, perRecordCompletion: { record in
            notMyMeetings.append(Meeting(record: record))
        }) {
            guard let recordIDs = notMyMeetings.map({$0.manager?.recordID}) as? [CKRecord.ID] else {
                notMyMeetings.forEach { meeting in
                    self.appendMeeting(meeting: meeting)
                }
                return
            }
            
            self.cloud.fetchRecords(recordIDs: recordIDs, desiredKeys: ["name"]) { (records, _) in
                guard let userNames = records else { return }
                print(userNames)
                
                for meeting in notMyMeetings {
                    if let name = userNames[meeting.manager!.recordID]?.value(forKey: "name") as? String {
                        meeting.managerName = name
                    }
                    self.appendMeeting(meeting: meeting)
                }
                
                DispatchQueue.main.async {
                    self.meetingsToShow = self.meetings[0]
                    self.tableView.reloadData()
                }
            }
        }
        
        //Realiza o fetch das reunioes que sao suas
        cloud.readRecords(recorType: "Meeting", predicate: predicateManager, desiredKeys: nil, perRecordCompletion: { record in
            let meeting = Meeting.init(record: record)
            meeting.managerName = self.defaults.string(forKey: "givenName")
            self.appendMeeting(meeting: meeting)
        }) {
            DispatchQueue.main.async {
                self.meetingsToShow = self.meetings[0]
                self.tableView.reloadData()
            }
        }
    }
    
    private func appendMeeting(meeting: Meeting){
        if let finalDate = meeting.finalDate, finalDate > Date(timeIntervalSinceNow: 0){
            self.meetings[0].append(meeting)
        } else {
            self.meetings[1].append(meeting)
        }
    }
}

//MARK: - Table View Delegate/DataSource
extension MyMeetingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filterring ? self.filtered.count : self.meetingsToShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MyMeetingsTableViewCell
        
        let meetingsArray = self.filterring ? self.filtered : self.meetingsToShow
        
        cell.meetingName.text = meetingsArray[indexPath.row].theme
        cell.managerName.text = meetingsArray[indexPath.row].managerName
        
        cell.colorView.layer.cornerRadius = 30
        if let colorHex = meetingsArray[indexPath.row].color {
            let color = UIColor(hexString: colorHex)
            cell.colorView.backgroundColor = color
        }
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let meetingsArray = self.filterring ? self.filtered : self.meetingsToShow

        if meetingsArray[indexPath.row].finished {
            performSegue(withIdentifier: "finishedMeeting", sender: self.meetingsToShow[indexPath.row])
        } else {
            performSegue(withIdentifier: "unfinishedMeeting", sender: self.meetingsToShow[indexPath.row])
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "finishedMeeting" {
            let viewDestination = segue.destination as! FinishedMeetingViewController
            viewDestination.currMeeting = sender as? Meeting
        } else if segue.identifier == "unfinishedMeeting"{
            let viewDestination = segue.destination as! UnfinishedMeetingViewController
            viewDestination.currMeeting = sender as? Meeting
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
