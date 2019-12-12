//
//  FinishedReunionViewController.swift
//  MeetingiOS
//
//  Created by Paulo Ricardo on 11/29/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import UIKit
import CloudKit


/// Essa View será exibida após a seleção de uma Meeting que já foi encerrada.
class FinishedMeetingViewController: UIViewController {

    //MARK:- IBOutlets
    @IBOutlet var topicsTableView: UITableView!
    
    //MARK:- Properties
    var topics = [[Topic]]()
    var topicsToShow = [Topic]()
    var currMeeting: Meeting!
    
    fileprivate var filtered = [Topic]()
    fileprivate var filterring = false
    
    private let cloud = CloudManager.shared
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        topics.append([Topic]())
        topics.append([Topic]())
        
        // MARK: Nav Controller Settings
        self.navigationItem.title = self.currMeeting.theme
        self.setUpSearchBar(segmentedControlTitles: ["Discussed", "Not discussed"])

        
        // MARK: Fetch dos topicos
        let topicIDs = currMeeting.topics.map({ (topic) -> CKRecord.ID in
            return topic.recordID
        })

        cloud.fetchRecords(recordIDs: topicIDs, desiredKeys: nil) { (recordsDic, _) in
            guard let topicsDic = recordsDic else { return }

            for (_, value) in topicsDic {
                let topic = Topic(record: value)

                if topic.discussed {
                    self.topics[0].append(topic)
                } else {
                    self.topics[1].append(topic)
                }
            }

            DispatchQueue.main.async {
                self.topicsToShow = self.topics[0]
                self.topicsTableView.reloadData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    /// Identificamos a passagem dessa ViewController para a ConclusionViewController e passamos o Topic selecionado na TableView
    ///  para então exibirmos suas Conclusions na ConclusionsViewController.
    /// - Parameters:
    ///   - segue: Default
    ///   - sender: Default
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "conclusions" {
            let vc = segue.destination as! ConclusionsViewController
            vc.topicToPresentConclusions = sender as? Topic
        }
    }
}

//MARK: - Table View Settings
extension FinishedMeetingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.filterring ? self.filtered.count : self.topicsToShow.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FinishedTopicsTableViewCell
        
        let topicsArray = self.filterring ? self.filtered : self.topicsToShow
        
        cell.authorNameLabel.text = topicsArray[indexPath.row].authorName
        cell.topicDescriptionLabel.text = topicsArray[indexPath.row].topicDescription
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let topicsArray = self.filterring ? self.filtered : self.topicsToShow

        self.performSegue(withIdentifier: "conclusions", sender: topicsArray[indexPath.row])
    }
}

//MARK: - Search Settings
extension FinishedMeetingViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.topicsToShow = topics[searchController.searchBar.selectedScopeButtonIndex]
        
        if let text = searchController.searchBar.text, !text.isEmpty {
            
            self.filtered = self.topicsToShow.filter({ (topic) -> Bool in
                
                return (topic.topicDescription.lowercased().contains(text.lowercased()) || topic.authorName?.lowercased().contains(text.lowercased()) ?? false)
            })
            
            self.filterring = true
        } else {
            self.filterring = false
            self.filtered = [Topic]()
        }
        
        self.topicsTableView.reloadData()
    }
}

