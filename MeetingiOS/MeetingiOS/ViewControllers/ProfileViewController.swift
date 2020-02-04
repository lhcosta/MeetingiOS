//
//  ProfileViewController.swift
//  MeetingiOS
//
//  Created by Bernardo Nunes on 11/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import UIKit

class ProfileViewController: UITableViewController {
    
    //MARK:- IBOutlets
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var premiumBtn: UIButton!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var doneBtn: UIBarButtonItem!
    @IBOutlet weak var subscriptionView: UIView!
    
    //MARK:- Properties
    let defaults = UserDefaults.standard
    let cloud = CloudManager.shared
    var didComeFromLogin = false
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isModalInPresentation = true
        self.addShadowAndCornerInViews()
        
        fillTF()
    }
    
    //MARK:- IBActions
    
    @IBAction func didPressPremiumBtn(_ sender: Any) {
        
    }
    
    
    @IBAction func didPressDone(_ sender: Any) {
        let name = defaults.string(forKey: "givenName")
        let email = defaults.string(forKey: "email")
        var emailToUpdate: String?
        var nameToUpdate: String?
        
        if name != nameTF.text {
            nameToUpdate = nameTF.text
        }
        
        if email != emailTF.text {
            emailToUpdate = emailTF.text
        }
        
        User.updateUser(name: nameToUpdate, email: emailToUpdate) {
            DispatchQueue.main.async {
                if self.didComeFromLogin {
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func nameChanged(_ sender: Any) {
        
        if validateTextField(textField: nameTF) {
            doneBtn.isEnabled = true
        } else {
            doneBtn.isEnabled = false
        }
    }
    
    @IBAction func emailChanged(_ sender: Any) {
        
        if validateEmail(email: emailTF) {
            doneBtn.isEnabled = true
        } else {
            doneBtn.isEnabled = false
        }
    }
    
    //MARK:- Methods
    /// Validate if textfields are not empty
    ///
    /// - Parameter textField: text field to validate
    /// - Returns: bool value indicating validation
    private func validateTextField(textField: UITextField) -> Bool {
        
        guard let content = textField.text, !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            textField.text = ""
            
            return false
        }
        
        return true
    }
    
    /// Validates if text is in email format
    ///
    /// - Parameter email: textfield to be validated
    /// - Returns: bool value indicating validation
    private func validateEmail (email: UITextField) -> Bool {
        
        if !validateTextField(textField: email) {
            return false
        }
        
        let emailText = email.text!
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        if !emailTest.evaluate(with: emailText) {
            return false
        }
        
        return true
    }
    
    /// Method used to fill name and email textfields with userdefaults
    private func fillTF() {
        if let name = defaults.string(forKey: "givenName") {
            nameTF.text = name
        }
        
        if let email = defaults.string(forKey: "email") {
            emailTF.text = email
        }
    }
    
    //MARK:- Table View
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        super.tableView(tableView, heightForHeaderInSection: section)
        
        switch section {
            case 1:
                return 10
            default:
                break
        }
        
        return 30
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        super.tableView(tableView, viewForHeaderInSection: section)
        
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }
}

//MARK:- Add Shadow to Views
extension ProfileViewController {
    
    /// Adicionando bordas e sombra para as views.
    func addShadowAndCornerInViews() {
        self.infoView.setupCornerRadiusShadow()
        self.subscriptionView.setupCornerRadiusShadow()
        self.premiumBtn.setupCornerRadiusShadow()
    }
}
