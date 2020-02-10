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
        if textView.text == NSLocalizedString("Not specified.", comment: "") {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        viewController?.isChangedTopic = true
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.text.isEmpty {
            textView.text = NSLocalizedString("Not specified.", comment: "")
            textView.textColor = .placeholderText
        }
        
        viewController?.isChangedTopic = true
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        viewController?.topicToPresentConclusions.topicPorque = textView.text!
    }
}
