//
//  TvTableViewCell.swift
//  MeetingiOS
//
//  Created by Lucas Costa  on 31/01/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

import UIKit

class TvTableViewCell: UITableViewCell {
    
    /// Nome da TV
    @IBOutlet weak var tvName : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
