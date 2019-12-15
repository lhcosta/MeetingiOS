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
@objc class ContactTableViewController: UITableViewController {
    
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
    

        //MARK:- Navigation
        self.navigationItem.title = "Add participants"
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(sendingContactsToMeeting))
        
        self.setUpSearchBar(segmentedControlTitles: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.deselectContactInRow), name: NSNotification.Name(rawValue: "RemoveContact"), object: nil)
        
        self.contactTableViewManager.fetchingContacts {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated) 
        
        self.collectionView.delegate = contactCollectionView
        self.collectionView.dataSource = contactCollectionView
        self.animateCollection()
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
    
}

//MARK:- UICollectionView
extension ContactTableViewController {
    
    /// Animando a collection view. 
    func animateCollection() {
        UIView.animate(withDuration: 0.5) { 
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            self.view.layoutIfNeeded()
        }
    }
    
    
    /// Deselecionar um contanto que foi removido.
    @objc func deselectContactInRow() {
        self.contactTableView.reloadData()
        self.animateCollection()
    }
}

//MARK:- UISearchResultsUpdating
extension ContactTableViewController : UISearchResultsUpdating {
    
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
extension ContactTableViewController {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if contactCollectionView?.contacts.count == 0 && section == 0 {
            return 0
        }
        
        return section == 0 ? 44 : 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if contactCollectionView?.contacts.count == 0 && indexPath.section == 0 {
            return 0
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
}

//MARK:- ContactTableViewDelegate {
extension ContactTableViewController : ContactTableViewDelegate {
    
    func addContact(contact: Contact) {
                
        self.contactCollectionView?.addContact(contact)
        
        let indexPath = IndexPath(item: (self.contactCollectionView?.contacts.count ?? 1) - 1, section: 0)
                            
        self.animateCollection()
        
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
     
        self.animateCollection()
    }
}
