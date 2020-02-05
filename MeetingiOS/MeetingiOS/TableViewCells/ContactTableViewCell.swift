//
//  ContactTableViewCell.swift
//  MeetingiOS
//
//  Created by Lucas Costa  on 12/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    /// Nome do contato.
    @IBOutlet private weak var name: UILabel!
    
    /// Email do contato.
    @IBOutlet private weak var email: UILabel!
    
    /// Seleção do contato.
    @IBOutlet weak var imageSelect : UIImageView!
    
    /// Contato presente na célula
    var contact : Contact? {
        didSet {
            self.name.text = contact?.name
            self.email.text = contact?.email
        }
    }
    
}
