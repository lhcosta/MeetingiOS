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
    
    var meetings = [[Meeting]]()
    let cloud = CloudManager.shared
    let defaults = UserDefaults.standard
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Nav Controller settings
        self.navigationItem.title = "My Meetings"
        self.navigationItem.hidesBackButton = true
        self.navigationItem.largeTitleDisplayMode = .always
        
        // MARK: Query no CK
        guard let recordName = defaults.string(forKey: "recordName") else { return }
        let userReference = CKRecord.Reference(recordID: CKRecord.ID(recordName: recordName), action: .none)
        let predicateManager = NSPredicate(format:"manager = %@", userReference)
        let predicateEmployee = NSPredicate(format:"employees CONTAINS %@", userReference)
        
        var notMyMeetings: [Meeting] = []
        
        cloud.readRecords(recorType: "Meeting", predicate: predicateEmployee, desiredKeys: nil, perRecordCompletion: { record in
            notMyMeetings.append(Meeting.init(record: record))
        }) {
            let recordIDs = notMyMeetings.map({$0.record.recordID})
            
            self.cloud.fetchRecords(recordIDs: recordIDs, desiredKeys: ["name"]) { (records, _) in
                guard let userNames = records else { return }
                
                for meeting in notMyMeetings {
                    if let name = userNames[meeting.manager!.recordID]?.value(forKey: "name") as? String{
                        meeting.managerName = name
                    }
                    self.appendMeeting(meeting: meeting)
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        
        cloud.readRecords(recorType: "Meeting", predicate: predicateManager, desiredKeys: nil, perRecordCompletion: { record in
            let meeting = Meeting.init(record: record)
            meeting.managerName = self.defaults.string(forKey: "givenName")
            self.appendMeeting(meeting: meeting)
        }) {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func appendMeeting(meeting: Meeting){
        if let finalDate = meeting.finalDate, finalDate < Date(timeIntervalSinceNow: 0){
            self.meetings[0].append(meeting)
        } else {
            self.meetings[1].append(meeting)
        }
    }
    
    @IBAction func didChangeControl(_ sender: Any) {
        tableView.reloadData()
    }
}

extension MyMeetingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        meetings[segmentedControl.selectedSegmentIndex].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MyMeetingsTableViewCell
        
        let meetingsToShow = meetings[segmentedControl.selectedSegmentIndex]
        cell.meetingName.text = meetingsToShow[indexPath.row].theme
        cell.managerName.text = meetingsToShow[indexPath.row].managerName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let meetingsToShow = meetings[segmentedControl.selectedSegmentIndex]

        if meetingsToShow[indexPath.row].finished {
            performSegue(withIdentifier: "finishedMeeting", sender: meetingsToShow[indexPath.row])
        } else {
            performSegue(withIdentifier: "unfinishedMeeting", sender: meetingsToShow[indexPath.row])
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

//extension MyMeetingsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//
//    // MARK: - Data Source
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return meetings.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! MyMeetingsCollectionViewCell
//        cell.meetingTittleLabel.text = meetings[indexPath.row].theme
//        cell.managerName.text = meetings[indexPath.row].managerName
//
//        return cell
//    }
//
//    // MARK: - Delegate
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//
//        if meetings[indexPath.row].finished {
//            performSegue(withIdentifier: "finishedMeeting", sender: self)
//        } else {
//            performSegue(withIdentifier: "unfinishedMeeting", sender: meetings[indexPath.row])
//        }
//    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "finishedMeeting" {
//            let viewDestination = segue.destination as! UnfinishedMeetingViewController
//            viewDestination.currMeeting = sender as? Meeting
//        }
//    }
//
//
//    // MARK: - Flow Layout
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height * 0.2)
//    }
//
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return collectionView.frame.size.height * 0.05
//    }
//
//}
