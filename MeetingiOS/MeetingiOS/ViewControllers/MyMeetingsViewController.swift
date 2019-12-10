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
    
    var meetings: [Meeting] = []
    @IBOutlet var myMeetingsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myMeetingsCollectionView.delegate = self
        myMeetingsCollectionView.dataSource = self
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(nextScreen))
        self.navigationItem.title = "My Meetings"
        
        // MARK: Query no CK
        /// Testar quando tivermos valores validos (meetings criadas).
        /// Meetings que o usuário criou.
//        var predicate = NSPredicate(format:"manager = %@", defaults.string(forKey: "recordName") ?? "")
//        CloudManager.shared.readRecords(recorType: "Meeting", predicate: predicate, desiredKeys: nil, perRecordCompletion: { record in
//            self.meetings.append(Meeting.init(record: record))
//        }) {}
//        /// Meetings em que o usuário está como convidado.
//        predicate = NSPredicate(format:"employees CONTAINS %@", defaults.string(forKey: "recordName") ?? "")
//        CloudManager.shared.readRecords(recorType: "Meeting", predicate: predicate, desiredKeys: nil, perRecordCompletion: { record in
//            self.meetings.append(Meeting.init(record: record))
//        }) {
//            self.myMeetingsCollectionView.reloadData()
//        }

        // MARK: Simulação
        /// Serão substiuídos pelo query no CK.
        for i in 0...2 {
            let m1 = Meeting(record: CKRecord(recordType: "Meeting"))
            m1.theme = "unfinished Theme: \(i)"
            meetings.append(m1)
        }
        for i in 0...2 {
            let m1 = Meeting(record: CKRecord(recordType: "Meeting"))
            m1.theme = "finished Theme: \(i)"
            m1.finished = true
            meetings.append(m1)
        }
    }
    
    @objc func nextScreen() {
        self.performSegue(withIdentifier: "nextScreen", sender: nil)
    }
}


extension MyMeetingsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! MyMeetingsCollectionViewCell
        cell.meetingTittleLabel.text = meetings[indexPath.row].theme
        return cell
    }
    
    
    // MARK: - Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if meetings[indexPath.row].finished {
            performSegue(withIdentifier: "finishedMeeting", sender: self)
        } else {
            performSegue(withIdentifier: "unfinishedMeeting", sender: self)
        }
    }
    
    
    // MARK: - Flow Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height * 0.2)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView.frame.size.height * 0.05
    }
    
}
