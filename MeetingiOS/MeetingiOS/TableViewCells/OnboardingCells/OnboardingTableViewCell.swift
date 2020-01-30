//
//  OnboardingTableViewCell.swift
//  MeetingiOS
//
//  Created by Lucas Costa  on 30/01/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

import UIKit

class OnboardingTableViewCell: UITableViewCell {

    @IBOutlet weak var title : UILabel!
    @IBOutlet weak var descriptionText : UILabel!
    @IBOutlet weak var imageDescription : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.imageDescription.widthAnchor.constraint(equalToConstant: 60).isActive = true
        //self.imageDescription.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
