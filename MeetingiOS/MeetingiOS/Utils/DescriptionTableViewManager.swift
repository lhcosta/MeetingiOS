//
//  DescriptionTableViewCell.swift
//  MeetingiOS
//
//  Created by Caio Azevedo on 12/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import Foundation
import UIKit

/// Gerenciador da Description de um tópico.
class DescriptionTableViewManager: NSObject {
    
    /// View controller que ela está localizada.
    weak var viewController: ConclusionsViewController?
    
}

//MARK:- TextFieldDelegate
extension DescriptionTableViewManager: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if viewController?.topicToPresentConclusions.topicPorque.isEmpty ?? true {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        viewController?.topicToPresentConclusions.topicPorque = textView.text!
    }
}
