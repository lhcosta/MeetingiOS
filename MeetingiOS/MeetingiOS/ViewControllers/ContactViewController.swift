//
//  ContactViewController.swift
//  MeetingiOS
//
//  Created by Lucas Costa  on 03/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

/// View Controller para selecionar os contatos para reunião
@objc class ContactViewController: UITableViewController {
    
    //MARK:- IBOutlets
    @IBOutlet weak var collectionView : UICollectionView!
    @IBOutlet private weak var contactTableView : UITableView!
    
    //MARK:- Properties
    private var contactTableViewManager : ContactTableView!
    
    @objc var contactCollectionView : ContactCollectionView?
    
    //MARK:- Delegates
    @objc weak var contactDelegate : MeetingDelegate?
    
    //MARK:- Computed Properties
    private var isSearchNameEmpty : Bool {
        self.navigationItem.searchController?.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering : Bool {
        return !isSearchNameEmpty
    }
    
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.register(UINib(nibName: "ContactCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ContactCollectionCell")
        
        self.contactTableViewManager = ContactTableView(self)
        self.setupTableViewContacts()
        self.setupNavigationController()
        
        self.collectionView.delegate = contactCollectionView
        self.collectionView.dataSource = contactCollectionView
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.deselectContactInRow), name: NSNotification.Name(rawValue: "RemoveContact"), object: nil)
        
        
        switch CNContactStore.authorizationStatus(for: .contacts) {
            
            case .authorized, .notDetermined:
                
                self.contactTableViewManager.fetchingContacts { (acess) in
                    if acess {
                        DispatchQueue.main.async {
                            self.contactTableView.reloadData()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
            }
            
            
            case .restricted, .denied:
                
                let alert = UIAlertController(title: nil, message: "This app requires access to Contacts to proceed. Would you like to open settings and grant permission to contacts?", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { action in
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                })
                
                present(alert, animated: true)
            
            default:
                break
        }
        
        
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// Setup inicial da table view dos contatos.
    func setupTableViewContacts() {        
        self.contactTableView.delegate = contactTableViewManager
        self.contactTableView.dataSource = contactTableViewManager
        self.contactTableView.allowsSelectionDuringEditing = true
        self.contactTableView.allowsMultipleSelection = true
        self.contactTableView.allowsMultipleSelectionDuringEditing = true
        self.contactTableView.register(UINib(nibName: "ContactTableViewCell", bundle: nil), forCellReuseIdentifier: "ContactTableViewCell")
    }
    
    @objc func sendingContactsToMeeting() {
        self.contactDelegate?.getRecordForSelectedUsers()
        self.navigationController?.popViewController(animated: true)
    }
    
}

//MARK:- UINavigationController
extension ContactViewController {
    
    /// Configurando navigation controller
    func setupNavigationController() {
        
        self.navigationItem.title = "Add participants"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(sendingContactsToMeeting))
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Contacts"
        
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesBackButton = true
        
        definesPresentationContext = true
    }
    
}

//MARK:- UICollectionView
extension ContactViewController {
    
    /// Animando a collection view. 
    func animateCollection() {
        UIView.animate(withDuration: 0.5) { 
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
    
    
    /// Deselecionar um contanto que foi removido.
    @objc func deselectContactInRow() {
        self.contactTableView.reloadData()
        self.animateCollection()
    }
}

//MARK:- UISearchResultsUpdating
extension ContactViewController : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let text = self.navigationItem.searchController?.searchBar.text?.lowercased() else {return}
        var filteringContacts : [Contact] = []
        
        self.contactTableViewManager.sortedContacts.forEach {
            $1.forEach { (contact) in
                if contact.name?.lowercased().contains(text) ?? false || contact.email?.lowercased().contains(text) ?? false {
                    filteringContacts.append(contact)
                }
            }
        }
        
        self.contactTableViewManager.filteredContacts = filteringContacts
        self.contactTableView.reloadData()  
    }
    
}

//MARK:- UITableViewDelegate
extension ContactViewController {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch section {
            case 0:
                if contactCollectionView?.contacts.count == 0 {
                    return 0
                }
                return 44
            case 2:
                return 0
            default:
                break
        }
        
        return super.tableView(tableView, heightForHeaderInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if contactCollectionView?.contacts.count == 0 && indexPath.section == 0 {
            return 0
        }
        
//        if indexPath.section == 2 {
//            return tableView.frame.height
//        }

        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 && indexPath.row == 0 {
            
            let contactViewController = CNContactViewController(forNewContact: nil)
            let navigation = UINavigationController(rootViewController: contactViewController)
            
            contactViewController.delegate = self
            navigation.view.layoutIfNeeded()
            
            self.navigationController?.present(navigation, animated: true, completion: nil)
        }
    }
    
}

//MARK:- ContactTableViewDelegate 
extension ContactViewController : ContactTableViewDelegate {
    
    func addContact(contact: Contact) {
        
        self.contactCollectionView?.addContact(contact)
        
        if contactCollectionView?.contacts.count == 1 {
            self.animateCollection()
        }
        
        let indexPath = IndexPath(item: (self.contactCollectionView?.contacts.count ?? 1) - 1, section: 0)
        self.collectionView.insertItems(at: [indexPath])
        self.collectionView.scrollToItem(at: indexPath, at: .right, animated: true)  
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false    
    }
    
    func removeContact(contact: Contact) {
        
        let index = self.contactCollectionView?.contacts.firstIndex(where: {
            return $0.email == contact.email
        })
        
        let indexPath = IndexPath(item: index!, section: 0)
        
        self.contactCollectionView?.removeContactIndex(indexPath.item)
        self.collectionView.deleteItems(at: [indexPath])  
        self.collectionView.layoutIfNeeded()
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false    
        
        if contactCollectionView?.contacts.count == 0 {
            self.animateCollection()
        }
        
    }
}

//MARK:- CNContactViewControllerDelegate
extension ContactViewController : CNContactViewControllerDelegate {
    
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        
        if let contact = contact {
            let newContact = Contact(contact: contact)
            self.addContact(contact: newContact)
        }
        
        viewController.dismiss(animated: true, completion: nil)
    }
}

