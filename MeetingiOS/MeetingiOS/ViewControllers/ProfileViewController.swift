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
    @IBOutlet weak var subscriptionView: UIView!
    @IBOutlet weak var editButtonName : UIButton!
    
    //MARK:- Properties
    let defaults = UserDefaults.standard
    let cloud = CloudManager.shared
    var didComeFromLogin = false
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isModalInPresentation = true
        self.nameTF.delegate = self
        
        self.nameTF.text = self.defaults.value(forKey: "givenName") as? String
        self.emailTF.text = self.defaults.value(forKey: "email") as? String
        
        self.addShadowAndCornerInViews()        
        
    }
    
    //MARK:- IBActions
    @IBAction func didPressPremiumBtn(_ sender: Any) {
        
    }
         
    @IBAction func didPressDone(_ sender: Any) {
        
        let name = defaults.string(forKey: "givenName")
        
        var nameToUpdate: String?
        
        if name != nameTF.text && !(nameTF.text?.isEmpty ?? false) {
            
            nameToUpdate = nameTF.text
            
            User.updateUser(name: nameToUpdate) {
                DispatchQueue.main.async {
                    if self.didComeFromLogin {
                        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
        
        self.dismiss(animated: true, completion: nil)
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

//MARK:- Change username
extension ProfileViewController : UITextFieldDelegate {
    
    ///Editando o nome de usuário
    @IBAction func didEditName(_ sender : Any) {
        self.nameTF.isUserInteractionEnabled = true
        self.nameTF.text = ""
        self.nameTF.becomeFirstResponder()
        self.editButtonName.isHidden = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        textField.isUserInteractionEnabled = false
        self.editButtonName.isHidden = false
        
        if(textField.text?.count ?? 0 == 0) {
            textField.text = self.defaults.value(forKey: "givenName") as? String
        } 
        
        return true
    }
    
}
