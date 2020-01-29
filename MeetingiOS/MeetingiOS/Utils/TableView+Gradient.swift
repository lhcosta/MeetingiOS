//
//  TableView+Gradient.swift
//  MeetingiOS
//
//  Created by Bernardo Nunes on 27/01/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    func setTableViewBackgroundGradient() {
        let topColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        let bottomColor = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1)
        
        let gradientBackgroundColors = [topColor.cgColor, bottomColor.cgColor]
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientBackgroundColors
        gradientLayer.locations = [0,1]
        
        gradientLayer.frame = self.bounds
        let backgroundView = UIView(frame: self.bounds)
        backgroundView.layer.insertSublayer(gradientLayer, at: 0)
        self.backgroundView = backgroundView
    }
}
