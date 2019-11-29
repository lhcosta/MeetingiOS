//
//  FinishedTopicsTableViewCell.swift
//  MeetingiOS
//
//  Created by Paulo Ricardo on 11/29/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import UIKit

class FinishedTopicsTableViewCell: UITableViewCell {
    
    @IBOutlet var topicDescriptionLabel: UILabel!
    @IBOutlet var authorNameLabel: UILabel!
    
    var thisCellTopic: Topic!
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
