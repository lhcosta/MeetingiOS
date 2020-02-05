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
        self.imageDescription.widthAnchor.constraint(equalToConstant: 50).isActive = true
        self.title.textColor = UIColor(named: "TitleColor")!
        self.descriptionText.textColor = UIColor(named: "DescriptionColor")!
    }
    
}



