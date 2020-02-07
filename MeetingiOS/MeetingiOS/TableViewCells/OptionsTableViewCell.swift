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
        self.contentView.layer.cornerRadius = 10
        self.clipsToBounds = true
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if self.isSelected {
            self.contentView.backgroundColor = UIColor(displayP3Red: 80/255, green: 126/255, blue: 254/255, alpha: 1)
            self.timeLbl.textColor = .white
            self.priceLabel.textColor = .white
        } else {
            self.contentView.backgroundColor = .white
            self.timeLbl.textColor = .black
            self.priceLabel.textColor = .black
        }
       
    }

}
