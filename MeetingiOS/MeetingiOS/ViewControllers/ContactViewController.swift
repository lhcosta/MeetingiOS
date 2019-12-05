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
class ContactViewController: UIViewController {
    
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
    private var contactCollectionView : ContactCollectionView?
    private var contactManager : ContactManager?
    
    //MARK:- Delegates
    weak var delegate : MeetingDelegate?
        
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
        self.setupContactCollectionView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.deselectContactInRow), name: NSNotification.Name(rawValue: "RemoveContact"), object: nil)
        
        self.fetchingContacts { 
            DispatchQueue.main.async {
                self.sortingContacts()
                self.tableView.reloadData()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

//MARK:- Fetching Contacts and Sending Contacts
private extension ContactViewController {
    
    func fetchingContacts(completionHandler : @escaping () -> Void) {
        
        CNContactStore().requestAccess(for: .contacts) { (acess, error) in
            if let error = error {
                NSLog("%@", "\(error)")
                return
            }
            
            if acess {
                
                self.contactManager = ContactManager()
                
                self.contactManager?.fetchContacts(email: { (contacts, error) in
                    if let error = error {
                        NSLog("%@", "\(error)")
                        return
                    }
                    
                    if let newContacts = contacts {
                        self.contacts = newContacts
                    }
                })
            }
        }
        
        completionHandler()
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
               
        self.contactCollectionView?.contacts.append(selectedContact)
        
        let indexPath = IndexPath(item: self.contactCollectionView!.contacts.count - 1, section: 0)
            
        self.collectionView.insertItems(at: [indexPath])
        self.collectionView.scrollToItem(at: indexPath, at: .right, animated: true)
        
        if isFiltering {
            self.searchName.resignFirstResponder()
            self.searchName.text = nil
            self.tableView.reloadData()
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
            return contact == selectedContact
        })
        
        cell?.accessoryType = .none
        selectedContact.isSelected = false
        
        let indexPath = IndexPath(item: index!, section: 0)
        
        self.contactCollectionView?.contacts.remove(at: index!)
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
    @IBAction func sendingContactsToMeeting() {
        
        var contactsHaveAccount = [CKRecord.Reference]()
        
        guard let allContacts = contactCollectionView?.contacts else {return}
        
        for contact in allContacts {
            
            CloudManager.shared.readRecords(recorType: "User", predicate: NSPredicate(format: "email = %@", contact.email!), desiredKeys: ["recordName"], perRecordCompletion: { (record) in
                contactsHaveAccount.append(CKRecord.Reference(record: record, action: .deleteSelf))
            }) { 
                self.delegate?.selectedContacts(contactsHaveAccount);
            }
        
        }
        
    }
    
}

//MARK:- Insert New Contact
private extension ContactViewController {
    
    @IBAction func addingNewContact(_ button : UIButton) {
        
        let contact = Contact(email: self.searchName.text!)
        
        self.contactCollectionView?.contacts.append(contact)
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
private extension ContactViewController {
    
    enum Animation {
        case show
        case notShow
    }
    
    /// Setup a collection view dos contatos selecionados.
    func setupContactCollectionView() {
        self.contactCollectionView = ContactCollectionView()
        self.collectionView.dataSource = contactCollectionView
        self.collectionView.delegate = contactCollectionView
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
