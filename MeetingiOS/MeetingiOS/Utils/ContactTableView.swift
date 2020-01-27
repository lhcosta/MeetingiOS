//
//  ContactTableView.swift
//  MeetingiOS
//
//  Created by Lucas Costa  on 12/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import Foundation
import Contacts
import ContactsUI

/// Delegate quando selecionados ou removidos contatos da table view.
protocol ContactTableViewDelegate : AnyObject {
    func addContact(contact : Contact)
    func removeContact(contact : Contact)
}

/// Classe model para a table view de contatos do usuário.
/// - Author: Lucas Costa

class ContactTableView : NSObject {
    
    //MARK:- UITableViewController
    private weak var contactViewController : ContactViewController!
    
    //MARK:- Properties
    var contacts : [String : [Contact]] = [:]
    var sortedContacts : [(key : String, value : [Contact])] = []
    var filteredContacts : [Contact] = []
    var contactManager = ContactManager()
    
    //MARK:- Delegates 
    private weak var delegate : ContactTableViewDelegate?
    
    /// Inicializando com uma view controller que possue a table view.
    /// - Parameter viewController: view controller responsável pela table view.
    init(_ viewController : ContactViewController) {
        self.contactViewController = viewController
        self.delegate = viewController
    }
    
}

//MARK:- UITableViewDelegate
extension ContactTableView : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 && !contactViewController.isFiltering {
            
            tableView.cellForRow(at: indexPath)?.isSelected = false
            
            let contact = CNContact()
            let newContactViewController = CNContactViewController(forNewContact: contact)
            newContactViewController.contactStore = CNContactStore()
            newContactViewController.delegate = self
        
            let navigationController = UINavigationController(rootViewController: newContactViewController)
        
            self.contactViewController.present(navigationController, animated: true, completion: nil)
                        
            return
        }
        
        guard let cell = tableView.cellForRow(at: indexPath) as? ContactTableViewCell else {return}
        var selectedContact : Contact
        
        if contactViewController.isFiltering {
            selectedContact = self.filteredContacts[indexPath.row]
        } else {
            selectedContact = self.sortedContacts[indexPath.section-1].value[indexPath.row]
        }
        
        cell.imageSelect.tintColor = UIColor(hexString: "#507EFE", alpha: 1)
        selectedContact.isSelected = true
        
        self.delegate?.addContact(contact: selectedContact)
    
        if contactViewController.isFiltering {
            UIView.animate(withDuration: 1, delay: 0.5, options: .curveEaseIn, animations: { 
                tableView.reloadData()
            }, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? ContactTableViewCell else {return}
        var selectedContact : Contact
        
        if contactViewController.isFiltering {
            selectedContact = self.filteredContacts[indexPath.row]
        } else {
            selectedContact = self.sortedContacts[indexPath.section-1].value[indexPath.row]
        }  
            
        cell.imageSelect.tintColor = UIColor(hexString: "#E3E3E3", alpha: 1)
        selectedContact.isSelected = false
        
        self.delegate?.removeContact(contact: selectedContact)
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if !contactViewController.isFiltering {
            let indexes = sortedContacts.map {
                $0.key
            }
            return indexes
        }
        
        return nil
    }
}

//MARK:- UITableDataSource
extension ContactTableView : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {        
        return contactViewController.isFiltering == true ? 1 : (self.sortedContacts.count + 1)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if contactViewController.isFiltering {
            return NSLocalizedString("Search Results", comment: "")
        }
        
        if section == 0 {
            return NSLocalizedString("Contacts", comment: "")
        }
        
        return String(self.sortedContacts[section-1].key)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if contactViewController.isFiltering {
            return self.filteredContacts.count
        }
        
        if section == 0 {
            return 1
        }
                
        return self.sortedContacts[section-1].value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 && !contactViewController.isFiltering {
            return tableView.dequeueReusableCell(withIdentifier: "NewContactCell", for: indexPath) as! NewContactTableViewCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell", for: indexPath) as! ContactTableViewCell 
        
        if contactViewController.isFiltering {
            cell.contact = self.filteredContacts[indexPath.row]
        } else {
            cell.contact = self.sortedContacts[indexPath.section-1].value[indexPath.row]
        }
        
        if cell.contact?.isSelected ?? false {
            cell.imageSelect.tintColor = UIColor(hexString: "#507EFE", alpha: 1)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        } else {
            cell.imageSelect.tintColor = UIColor(hexString: "#E3E3E3", alpha: 1)
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        return cell
    }
}

//MARK:- Fetching Contacts and Sending Contacts
extension ContactTableView {
    
    /// Realizando a busca de todos os contatos que possuem email.
    /// - Parameter completionHandler: closure com paramêtro para acesso ou não aos contatos.
     func fetchingContacts(completionHandler : @escaping (Bool) -> Void) {
        
        var allContacts : [String : [Contact]] = [:]

        CNContactStore().requestAccess(for: .contacts) { (acess, error) in
            if let error = error {
                NSLog("%@", "\(error)")
                completionHandler(false)
                return
            }
            
            if acess {
                
                self.contactManager.fetchContacts(email: { (contacts, error) in
                    if let error = error {
                        NSLog("%@", "\(error)")
                        return
                    }
                    
                    if let newContacts = contacts {
                        allContacts = newContacts
                    }
                })
                
                self.sortingContacts(allContacts)                
            }
            
            completionHandler(acess)
        }        
    }
}

//MARK:- Sorting Contacts
private extension ContactTableView {
    
    /// Ordenação dos contatos.
    /// - Parameter contacts: todos os contatos do usuário que possuem email separados por chaves.
    func sortingContacts(_ contacts : [String : [Contact]]) {
        
        self.contacts = contacts
        
        self.sortedContacts = contacts.sorted(by: { (lhs, rhs) -> Bool in
            return lhs.key < rhs.key
        })
    }
}

//MARK:- CNContactViewController
extension ContactTableView : CNContactViewControllerDelegate {
    
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
                        
        if contact == nil  {
            viewController.dismiss(animated: true, completion: nil)
        } else {
            
            if let email = contact?.emailAddresses.first?.value as String?, !email.isEmpty, contact?.givenName.count ?? 0 > 0 {
                
                let contact = Contact(contact: contact!)
                self.contactViewController.addContact(contact: contact)
                
                viewController.dismiss(animated: true, completion: nil)
                
            } else {
                
                let alert = UIAlertController(title: NSLocalizedString("Error to add contact", comment: ""), message: NSLocalizedString("Name or email empty", comment: ""), preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                    viewController.dismiss(animated: true, completion: nil)
                }))
                
                viewController.present(alert, animated: true, completion: nil)            
            }
        }
    }
}
