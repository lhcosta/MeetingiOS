//
//  PremiumTableTableViewController.swift
//  MeetingiOS
//
//  Created by Bernardo Nunes on 03/02/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

import UIKit

class PremiumTableTableViewController: UITableViewController {

    @IBOutlet weak var firstBenefit: UILabel!
    @IBOutlet weak var secondBenefit: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let originalStrings = ["• Create unlimited meetings", "• Have unlimited meeting invitations"]
        
        let range = NSRange(location:0, length:1)
        let attributedStrings = originalStrings.map { (original) -> NSMutableAttributedString in
            let newString = NSMutableAttributedString(string: original, attributes: [NSAttributedString.Key.font:UIFont(name: "SF-Pro-Text", size: 18.0)!])
            newString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(displayP3Red: 0, green: 63, blue: 255, alpha: 1)], range: range)
            return newString
        }
        
        firstBenefit.attributedText = attributedStrings[0]
        secondBenefit.attributedText = attributedStrings[1]
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }

  

}
