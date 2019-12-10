//
//  ConclusionsViewController.swift
//  MeetingiOS
//
//  Created by Paulo Ricardo on 11/29/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import UIKit

class ConclusionsViewController: UIViewController {
    
    @IBOutlet var authorNameLabel: UILabel!
    @IBOutlet var topicTimeLabel: UILabel!
    @IBOutlet var conclusionsTableView: UITableView!
    
    var topicToPresentConclusions: Topic!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        conclusionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        conclusionsTableView.delegate = self
        conclusionsTableView.dataSource = self
    }
    
    
}


extension ConclusionsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topicToPresentConclusions.conclusions.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conCell", for: indexPath) as! ConclusionTableViewCell
        
        
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
