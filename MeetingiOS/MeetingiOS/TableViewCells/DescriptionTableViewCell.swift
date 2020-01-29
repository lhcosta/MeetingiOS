//
//  DescriptionTableViewCell.swift
//  MeetingiOS
//
//  Created by Caio Azevedo on 12/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import Foundation
import UIKit

class DescriptionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet var descriptionTextField: UITextField!
    
    var viewController: ConclusionsViewController?
}


extension DescriptionTableViewCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        viewController?.topicToPresentConclusions.topicPorque = textField.text!
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
