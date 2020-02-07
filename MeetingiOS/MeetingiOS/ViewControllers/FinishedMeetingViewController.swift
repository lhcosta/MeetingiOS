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
    var topics: [[Topic]] = [[],[]]
    var topicsToShow = [Topic]()
    var currMeeting: Meeting!
    var scopeSelected = 0
    var timerView: UIView?
    
    fileprivate var filtered = [Topic]()
    fileprivate var filtering = false
    
    private let cloud = CloudManager.shared
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Nav Controller Settings
        self.navigationItem.title = self.currMeeting.theme
        self.setUpSearchBar(segmentedControlTitles: [NSLocalizedString("Topics discussed", comment: ""), NSLocalizedString("Topics not discussed", comment: "")])
        
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
        
        self.navigationController?.navigationBar.subviews[2].addSubview(self.topTimer(time: self.currMeeting.duration ?? "00:00"))
        UIView.animate(withDuration: 0.25) {
            self.timerView?.alpha = 1
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let _ = self.timerView else { return }
        self.timerView?.removeFromSuperview()
    }
    
    
    @IBAction func infoButton(_ sender: Any) {
        performSegue(withIdentifier: "conclusions", sender: sender)
    }
    
    
    
    /// Identificamos a passagem dessa ViewController para a ConclusionViewController e passamos o Topic selecionado na TableView
    ///  para então exibirmos suas Conclusions na ConclusionsViewController.
    /// - Parameters:
    ///   - segue: Default
    ///   - sender: Default
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "conclusions" {
            guard let navigation = segue.destination as? UINavigationController else {return}
            
            guard let vc = navigation.viewControllers.first as? ConclusionsViewController else { return }
            
            if let button = sender as? UIButton {
                
                guard let cell = button.superview?.superview?.superview as? FinishedTopicsTableViewCell else {
                    return
                }
                
                let indexPath = topicsTableView.indexPath(for: cell)
                let topicsArray = self.filtering ? self.filtered : self.topicsToShow
                vc.topicToPresentConclusions = topicsArray[indexPath!.section]
            }
        }
    }
    
    
    @objc func segmentChanged() {
        self.topicsTableView.reloadData()
    }
    
    
    func topTimer(time: String) -> UIView {

        let navigationBarHeight = CGFloat((self.navigationController?.navigationBar.subviews[2].frame.height)!)
        let navigationBarWidth = CGFloat((self.navigationController?.navigationBar.subviews[2].frame.width)!)
        
        let clock = UIImageView(image: UIImage(named: "clock"))
        
        let font = UIFont(name: "SF Pro Text", size: 17)
        let timeLabel = UILabel(frame: CGRect(x: clock.frame.width*2, y: 0, width: 0, height: 0))
        timeLabel.font = font
        timeLabel.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        timeLabel.backgroundColor = .clear
        timeLabel.textColor = UIColor(named: "TitleColor")
        timeLabel.text = time
        timeLabel.sizeToFit()
        
        let timerView = UIView(frame: CGRect(x: navigationBarWidth*0.95, y: navigationBarHeight*0.55, width: clock.frame.width*2 + timeLabel.frame.width, height: clock.frame.height))
        timerView.layer.anchorPoint  = CGPoint(x: 1.5, y: 1)
        timerView.backgroundColor = .clear

        timerView.addSubview(timeLabel)
        timerView.addSubview(clock)
        timerView.alpha = 0
        
        self.timerView = timerView
        return timerView
    }
}

//MARK: - Table View Settings
extension FinishedMeetingViewController: UITableViewDelegate, UITableViewDataSource {
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
//        return self.filterring ? self.filtered.count : self.topicsToShow.count
//    }
//
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FinishedTopicsTableViewCell
//
//        let topicsArray = self.filterring ? self.filtered : self.topicsToShow
//
//        cell.authorNameLabel.text = topicsArray[indexPath.row].authorName
//        cell.topicDescriptionLabel.text = topicsArray[indexPath.row].topicDescription
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        let topicsArray = self.filterring ? self.filtered : self.topicsToShow
//
//        self.performSegue(withIdentifier: "conclusions", sender: topicsArray[indexPath.row])
//    }
    
    /// Usamos apenas uma Cell em cada Section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    /// A quantidade de dados será exibida em cada Section e não nas Cells.
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.filtering ? self.filtered.count : self.topicsToShow.count
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FinishedTopicsTableViewCell

        let topicsArray = self.filtering ? self.filtered : self.topicsToShow

        cell.authorNameLabel.text = topicsArray[indexPath.section].authorName
        cell.topicDescriptionLabel.text = topicsArray[indexPath.section].topicDescription

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height * 0.2
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
            
            self.filtering = true
        } else {
            self.filtering = false
            self.filtered = [Topic]()
        }
        
        self.topicsTableView.reloadData()
    }
}
