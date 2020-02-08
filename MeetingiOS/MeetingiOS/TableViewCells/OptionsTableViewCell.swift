//
//  OptionsTableViewCell.swift
//  MeetingiOS
//
//  Created by Bernardo Nunes on 04/02/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

import UIKit

class OptionsTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.setupCorners()
        self.setupShadow()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if self.isSelected {
            self.contentView.backgroundColor = UIColor(displayP3Red: 80/255, green: 126/255, blue: 254/255, alpha: 1)
            self.timeLbl.textColor = .white
            self.priceLabel.textColor = .white
        } else {
            self.contentView.backgroundColor = UIColor(named: "ColorTableViewCell")
            if traitCollection.userInterfaceStyle == .light {
                self.timeLbl.textColor = .black
                self.priceLabel.textColor = .black
            }
        }
       
    }

}
