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
    
//        
//    //MARK:- Delegates
    @objc weak var contactDelegate : MeetingDelegate?
//    
//    //MARK:- Computed Properties
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
    
    enum Animation {
        case show
        case notShow
    }
    
    /// Animando a collection view. 
    /// - Parameter direction: mostrar ou esconder.
    func animateCollection(_ type : Animation) {
        UIView.animate(withDuration: 0.5) { 
            self.collectionView.isHidden = type == .show ? false : true 
            self.view.layoutIfNeeded()
        }
    }
    
    
    /// Deselecionar um contanto que foi removido.
    @objc func deselectContactInRow() {
        
        self.contactTableView.reloadData()
        
        if self.contactCollectionView?.contacts.count == 0 {
            self.animateCollection(.notShow)
        }
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
        return section == 0 ? 44 : 0
    }
}
