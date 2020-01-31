//
//  WelcomeOnboardingTableViewCell.swift
//  MeetingiOS
//
//  Created by Lucas Costa  on 30/01/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

import UIKit

class WelcomeOnboardingTableViewCell: UITableViewCell {

    @IBOutlet private weak var welcomeLabel : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.changeColorWelcomeText()
    }
    
}

//MARK: - Change Color Label
private extension WelcomeOnboardingTableViewCell  {
    
    func changeColorWelcomeText() {
        
        let welcomeText = NSLocalizedString("Welcome to Meetings", comment: "") as NSString
        let range = welcomeText.range(of: "Meetings")
        
        let mutableString = NSMutableAttributedString(string: welcomeText as String)
        mutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.blue, range: range)
        
        welcomeLabel.attributedText = mutableString
    }
}
