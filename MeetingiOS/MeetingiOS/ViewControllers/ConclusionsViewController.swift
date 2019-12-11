//
//  ConclusionsViewController.swift
//  MeetingiOS
//
//  Created by Paulo Ricardo on 11/29/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import UIKit

class ConclusionsViewController: UIViewController {
    
    @IBOutlet weak var viewTopic: UIView!
    @IBOutlet weak var viewAuthor: UIView!
    @IBOutlet weak var viewTimer: UIView!
    
    
    @IBOutlet var authorNameLabel: UILabel!
    @IBOutlet var topicTimeLabel: UILabel!
    @IBOutlet var conclusionsTableView: UITableView!
    
    var topicToPresentConclusions: Topic!
    var testTopics = [String()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneAction))
        
        navigationItem.title = "Details"
        
        
        conclusionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        conclusionsTableView.delegate = self
        conclusionsTableView.dataSource = self
        
        viewTopic.layer.cornerRadius = 10
        viewAuthor.layer.cornerRadius = 10
        viewTimer.layer.cornerRadius = 10
    }
    
    @objc func doneAction() {
        print("Done")
    }
    
    
}


extension ConclusionsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testTopics.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conCell", for: indexPath) as! ConclusionTableViewCell
        
        cell.textConclusion.text = testTopics[indexPath.row]
        cell.textConclusion.delegate = self
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "Conclusion"
    }
}

extension ConclusionsViewController: UITextFieldDelegate{
    public func textFieldDidEndEditing(_ textField: UITextField) {
        self.testTopics.append(textField.text ?? "Empty")
        self.conclusionsTableView.reloadData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
