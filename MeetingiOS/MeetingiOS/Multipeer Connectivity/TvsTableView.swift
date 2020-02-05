//
//  TvsTableView.swift
//  MeetingiOS
//
//  Created by Lucas Costa  on 31/01/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

import UIKit

/// Tvs disponíveis para exibição da reunião.
class TvsTableView: UITableView {
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 20
        self.clipsToBounds = true     
        self.register(UINib(nibName: "TvTableViewCell", bundle: nil), forCellReuseIdentifier: "TvCell")
    }
}

