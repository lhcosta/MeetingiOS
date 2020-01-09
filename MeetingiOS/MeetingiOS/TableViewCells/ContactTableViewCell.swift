//
//  ContactTableViewCell.swift
//  MeetingiOS
//
//  Created by Lucas Costa  on 12/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    @IBOutlet private weak var name: UILabel!
    @IBOutlet private weak var email: UILabel!
    @IBOutlet weak var imageSelect : UIImageView!
    
    var contact : Contact? {
        didSet {
            self.name.text = contact?.name
            self.email.text = contact?.email
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
