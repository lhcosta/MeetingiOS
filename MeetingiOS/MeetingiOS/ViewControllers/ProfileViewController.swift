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
    
    //MARK:- Properties
    let defaults = UserDefaults.standard
    let cloud = CloudManager.shared
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let topColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        let bottomColor = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1)
        
        setTableViewBackgroundGradient(sender: self, topColor, bottomColor)
        
        if let name = defaults.string(forKey: "givenName") {
            nameTF.text = name
        }
        
        guard let email = defaults.string(forKey: "email") else { return }
        emailTF.text = email
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
                self.dismiss(animated: true, completion: nil)
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
    
    func setTableViewBackgroundGradient(sender: UITableViewController, _ topColor:UIColor, _ bottomColor:UIColor) {

        let gradientBackgroundColors = [topColor.cgColor, bottomColor.cgColor]

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientBackgroundColors
        gradientLayer.locations = [0,1]

        gradientLayer.frame = sender.tableView.bounds
        let backgroundView = UIView(frame: sender.tableView.bounds)
        backgroundView.layer.insertSublayer(gradientLayer, at: 0)
        sender.tableView.backgroundView = backgroundView
    }
    
    //MARK:- Table View
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }
}
