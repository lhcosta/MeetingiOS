//
//  ContactTableView.swift
//  MeetingiOS
//
//  Created by Lucas Costa  on 12/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import Foundation
import Contacts

class ContactTableView : NSObject {
    
    //MARK:- UITableViewController
    private var contactViewController : ContactTableViewController!
    
    //MARK:- Properties
    var sortedContacts : [(key : String, value : [Contact])] = []
    var filteredContacts : [Contact] = []
    var contactManager = ContactManager.shared()
    var selectedContacts : [Contact] = []
    
    init(_ viewController : ContactTableViewController) {
        self.contactViewController = viewController
    }
    
        
    
}

//MARK:- UITableViewDelegate
extension ContactTableView : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! ContactTableViewCell
        var selectedContact : Contact
        
        if contactViewController.isFiltering {
            selectedContact = self.filteredContacts[indexPath.row]
        } else {
            selectedContact = self.sortedContacts[indexPath.section].value[indexPath.row]
        }
        
        cell.imageSelect.tintColor = UIColor(hexString: "#507EFE", alpha: 1)
        selectedContact.isSelected = true
        
//        if self.collectionView.isHidden {
//            self.animateCollection(.show)
//        }
//        
//        self.contactCollectionView?.addContact(selectedContact)
//        
//        let indexPath = IndexPath(item: (self.contactCollectionView?.contacts.count ?? 1) - 1, section: 0)
        
        contactViewController.collectionView.insertItems(at: [indexPath])
        contactViewController.collectionView.scrollToItem(at: indexPath, at: .right, animated: true)  
        contactViewController.collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        if contactViewController.isFiltering {
            UIView.animate(withDuration: 1, delay: 0.5, options: .curveEaseIn, animations: { 
                tableView.reloadData()
            }, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! ContactTableViewCell
        var selectedContact : Contact
        
        if contactViewController.isFiltering {
            selectedContact = self.filteredContacts[indexPath.row]
        } else {
            selectedContact = self.sortedContacts[indexPath.section].value[indexPath.row]
        }  
//        
//        let index = self.contactCollectionView?.contacts.firstIndex(where: { (contact) -> Bool in
//            return contact.email == selectedContact.email
//        })
//        
        cell.imageSelect.tintColor = UIColor(hexString: "#E3E3E3", alpha: 1)
        selectedContact.isSelected = false
        
//        let indexPath = IndexPath(item: index!, section: 0)
        
//        self.contactCollectionView?.removeContactIndex(indexPath.item)
//        self.collectionView.deleteItems(at: [indexPath])  
        
//        if self.contactCollectionView?.contacts.count == 0 {
//            self.animateCollection(.notShow)
//        }
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
        return contactViewController.isFiltering == true ? 1 : self.sortedContacts.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if contactViewController.isFiltering {
            return "Search Results"
        }
        
        return String(self.sortedContacts[section].key)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if contactViewController.isFiltering {
            return self.filteredContacts.count
        }
        
        let elements = self.sortedContacts[section].value
        
        return elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell", for: indexPath) as! ContactTableViewCell 
        
        if contactViewController.isFiltering {
            cell.contact = self.filteredContacts[indexPath.row]
        } else {
            cell.contact = self.sortedContacts[indexPath.section].value[indexPath.row]
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
    
     func fetchingContacts(completionHandler : @escaping () -> Void) {
        
        var allContacts : [String : [Contact]] = [:]

        CNContactStore().requestAccess(for: .contacts) { (acess, error) in
            if let error = error {
                NSLog("%@", "\(error)")
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
            }
            
            self.sortingContacts(allContacts)
            completionHandler()
        }
    }
}

//MARK:- Sorting Contacts and Sending Contacts
private extension ContactTableView {
    
    /// Ordenar os contatos.
    func sortingContacts(_ contacts : [String : [Contact]]) {
        self.sortedContacts = contacts.sorted(by: { (lhs, rhs) -> Bool in
            return lhs.key < rhs.key
        })
    }
    
//    ///Enviando Contatos
//    @objc func sendingContactsToMeeting() {
//        self.contactDelegate?.getRecordForSelectedUsers()
//        self.navigationController?.popViewController(animated: true)
//    }
    
}
