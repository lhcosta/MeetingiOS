//
//  ContactViewController.swift
//  MeetingiOS
//
//  Created by Lucas Costa  on 03/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import UIKit
import Contacts

/// View Controller para selecionar os contatos para reunião
@objc class ContactViewController: UIViewController {
    
    //MARK:- IBOutlets
    @IBOutlet private weak var tableView : UITableView!
    @IBOutlet private weak var collectionView : UICollectionView!
    @IBOutlet private weak var searchName : UISearchBar!
    @IBOutlet private weak var titleParticipants : UIView!
    @IBOutlet private weak var addNewContact : UIButton!
    
    //MARK:- Properties
    private var contacts : [String : [Contact]] = [:]
    private var sortedContacts : [(key : String, value : [Contact])] = []
    private var filteringContacts : [Contact] = []
    private var contactManager = ContactManager.shared()
    private var selectedContacts : [Contact] = []
    @objc var contactCollectionView : ContactCollectionView?
    
    //MARK:- Delegates
    @objc weak var contactDelegate : MeetingDelegate?
    
    //MARK:- Computed Properties
    private var isSearchNameEmpty : Bool {
        let notHaveName = searchName.text?.isEmpty ?? true 
        
        if notHaveName {
            self.searchName.resignFirstResponder()
        }
        
        return notHaveName
    }
    
    private var isFiltering : Bool {
        return !isSearchNameEmpty
    }
    
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.setupTableView()
        self.setupSearchBar()        
        
        //MARK:- Navigation
        self.navigationItem.title = "Contacts"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(sendingContactsToMeeting))
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.deselectContactInRow), name: NSNotification.Name(rawValue: "RemoveContact"), object: nil)
        
        self.fetchingContacts {
            
            for contant in self.selectedContacts {
                if(self.contacts[String(contant.name!.first!)]?.contains(where: {
                    return contant.email == $0.email}) ?? false){
                    contant.isSelected = true
                }
            }
            
            self.sortingContacts()  
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated) 
        
        self.collectionView.delegate = contactCollectionView
        self.collectionView.dataSource = contactCollectionView
        
        if(contactCollectionView?.contacts.count != 0) {
            animateCollection(.show)
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

//MARK:- Fetching Contacts and Sending Contacts
extension ContactViewController {
    
    private func fetchingContacts(completionHandler : @escaping () -> Void) {
        
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
                        self.contacts = newContacts
                    }
                })
            }
            
            completionHandler()
        }
    }
    
}


//MARK:- UITableViewDataSource
extension ContactViewController : UITableViewDataSource {
    
    /// Setup table view contatos.
    func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsSelectionDuringEditing = true
        self.tableView.allowsMultipleSelection = true
        self.tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return isFiltering == true ? 1 : self.sortedContacts.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if isFiltering {
            return "Search Results"
        }
        
        return String(self.sortedContacts[section].key)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering {
            return self.filteringContacts.count
        }
        
        let elements = self.sortedContacts[section].value
        
        return elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableCell", for: indexPath) as! ContactTableViewCell 
        
        if isFiltering {
            cell.contact = self.filteringContacts[indexPath.row]
        } else {
            cell.contact = self.sortedContacts[indexPath.section].value[indexPath.row]
        }
        
        if cell.contact?.isSelected ?? false {
            cell.accessoryType = .checkmark
            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        } else {
            cell.accessoryType = .none
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
        
        return cell
    }
}

//MARK:- UITableViewDelegate
extension ContactViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        var selectedContact : Contact
        
        if isFiltering {
            selectedContact = self.filteringContacts[indexPath.row]
        } else {
            selectedContact = self.sortedContacts[indexPath.section].value[indexPath.row]
        }
        
        cell?.accessoryType = .checkmark
        selectedContact.isSelected = true
        
        if self.collectionView.isHidden {
            self.animateCollection(.show)
        }
        
        self.contactCollectionView?.addContact(selectedContact)
        
        let indexPath = IndexPath(item: (self.contactCollectionView?.contacts.count ?? 1) - 1, section: 0)
        
        self.collectionView.insertItems(at: [indexPath])
        self.collectionView.scrollToItem(at: indexPath, at: .right, animated: true)        
        
        if isFiltering {
            UIView.animate(withDuration: 1, delay: 0.5, options: .curveEaseIn, animations: { 
                self.searchName.resignFirstResponder()
                self.searchName.text = nil
                self.tableView.reloadData()
            }, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        var selectedContact : Contact
        
        if isFiltering {
            selectedContact = self.filteringContacts[indexPath.row]
        } else {
            selectedContact = self.sortedContacts[indexPath.section].value[indexPath.row]
        }  
        
        let index = self.contactCollectionView?.contacts.firstIndex(where: { (contact) -> Bool in
            return contact.email == selectedContact.email
        })
        
        cell?.accessoryType = .none
        selectedContact.isSelected = false
        
        let indexPath = IndexPath(item: index!, section: 0)
        
        self.contactCollectionView?.removeContactIndex(indexPath.item)
        self.collectionView.deleteItems(at: [indexPath])  
        
        if self.contactCollectionView?.contacts.count == 0 {
            self.animateCollection(.notShow)
        }
    }
}



//MARK:- Sorting Contacts and Sending Contacts
private extension ContactViewController {
    
    /// Ordenar os contatos.
    func sortingContacts() {
        self.sortedContacts = self.contacts.sorted(by: { (lhs, rhs) -> Bool in
            return lhs.key < rhs.key
        })
    }
    
    ///Enviando Contatos
    @objc func sendingContactsToMeeting() {
        self.navigationController?.popViewController(animated: true)
    }
    
}

//MARK:- Insert New Contact
private extension ContactViewController {
    
    @IBAction func addingNewContact(_ button : UIButton) {
        
        let contact = Contact(email: self.searchName.text!)
        contact.isSelected = true
        
        self.contactCollectionView?.addContact(contact)
        
        self.collectionView.insertItems(at: [IndexPath(item: (self.contactCollectionView?.contacts.count ?? 1) - 1, section: 0)])
        
        if self.collectionView.isHidden {
            self.animateCollection(.show)
        }
        
        self.searchName.resignFirstResponder()
        self.searchName.text = nil
        self.tableView.reloadData()
        
    }
}

//MARK:- UICollectionView
extension ContactViewController {
    
    enum Animation {
        case show
        case notShow
    }
    
    /// Animando a collection view. 
    /// - Parameter direction: mostrar ou esconder.
    func animateCollection(_ type : Animation) {
        UIView.animate(withDuration: 0.5) { 
            self.collectionView.isHidden = type == .show ? false : true 
            self.titleParticipants.isHidden = type == .show ? false : true 
            self.view.layoutIfNeeded()
        }
    }
    
    
    /// Deselecionar um contanto que foi removido.
    @objc func deselectContactInRow() {
        
        self.tableView.reloadData()
        
        if self.contactCollectionView?.contacts.count == 0 {
            self.animateCollection(.notShow)
        }
        
    }
    
}

//MARK:- UISearchDelegate
extension ContactViewController : UISearchBarDelegate {
    
    /// Setup search bar 
    func setupSearchBar() {
        self.searchName.delegate = self
        self.searchName.autocapitalizationType = .none
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        var filterContacts : [Contact] = []
        
        if(isSearchNameEmpty) {
            self.tableView.reloadData()
            return
        }
        
        self.contacts.forEach {
            $1.forEach { (contact) in
                if contact.email?.lowercased().contains(searchText.lowercased()) ?? false || contact.name?.lowercased().contains(searchText.lowercased()) ?? false {
                    filterContacts.append(contact)
                }
            }
        }
        
        if filterContacts.count == 0 && searchText.validateEmail() {
            self.addNewContact.isEnabled = true
        } else {
            self.addNewContact.isEnabled = false
        }
        
        self.filteringContacts = filterContacts
        tableView.reloadData()       
        
    }
    
    
}
