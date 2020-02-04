//
//  UIAlertController+Loading.swift
//  MeetingiOS
//
//  Created by Lucas Costa  on 04/02/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

import Foundation

extension UIAlertController {
    
    /// Adicionando loading em uma alert controller
    @objc func addUIActivityIndicatorView() {
        
        let loadingIndicator = UIActivityIndicatorView(style: .medium)
        
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()
        
        self.view.addSubview(loadingIndicator)
        
        loadingIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        loadingIndicator.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
    }
    
}
