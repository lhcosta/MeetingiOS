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
    @IBOutlet private weak var contactTableView : UITableView!
    @IBOutlet weak var selectedContactsConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    
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
        
        self.contactTableViewManager = ContactTableView(self)
        self.setupTableViewContacts()
        self.setupNavigationController()
 
        collectionView.delegate = contactCollectionView
        collectionView.dataSource = contactCollectionView
        self.collectionView.register(UINib(nibName: "ContactCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ContactCollectionCell")
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.contactCollectionView?.contacts.count == 0 ? self.animateCollection(.hide) : self.animateCollection(.show)
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
        self.contactTableView.register(UINib(nibName: "NewContactTableViewCell", bundle: nil), forCellReuseIdentifier: "NewContactCell")
    }
    
    /// Confirmando contatos selecionados para a reunião.
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
    
    enum Animation {
        case show
        case hide
    }
    
    /// Animando a collection view. 
    /// - Parameter animation: mostrar ou esconder a collection view.
    func animateCollection(_ animation : Animation) {
        
        UIView.animate(withDuration: 0.5) { 
            switch animation {
                case .hide:
                    self.selectedContactsConstraint.constant = 0
                case .show:
                    self.selectedContactsConstraint.constant = self.view.frame.height * 0.15
            }
            
            self.view.layoutIfNeeded()
        }
    }
    
    /// Deselecionar um contanto que foi removido.
    @objc func deselectContactInRow() {
        
        self.contactTableView.reloadData()
        
        if contactCollectionView?.contacts.count == 0 {
            self.animateCollection(.hide)
        }
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

//MARK:- ContactTableViewDelegate 
extension ContactViewController : ContactTableViewDelegate {
    
    /// Adicionando contatos a collection view que foram selecionados.
    /// - Parameter contact: contato selecionado.
    func addContact(contact: Contact) {
        
        if contactCollectionView?.contacts.count == 0 {
            self.animateCollection(.show)
        }        
        
        self.contactCollectionView?.addContact(contact)
            
        let indexPath = IndexPath(item: (self.contactCollectionView?.contacts.count ?? 1) - 1, section: 0)
        
        self.collectionView.insertItems(at: [indexPath])
        self.collectionView.scrollToItem(at: indexPath, at: .right, animated: true)
        
        self.collectionView.layoutIfNeeded()
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false    
    }
    
    /// Removendo contatos da collection view que foram deselecionados.
    /// - Parameter contact: contato deselecionado.
    func removeContact(contact: Contact) {
        
        let index = self.contactCollectionView?.contacts.firstIndex(where: {
            return $0.email == contact.email
        })
        
        let indexPath = IndexPath(item: index!, section: 0)
        
          self.collectionView.scrollToItem(at: IndexPath(item: (self.contactCollectionView?.contacts.count ?? 1) - 1, section: 0), at: .left, animated: true)
        self.contactCollectionView?.removeContactIndex(indexPath.item)
        self.collectionView.deleteItems(at: [indexPath])  

        self.collectionView.layoutIfNeeded()
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false    
        
        if contactCollectionView?.contacts.count == 0 {
            self.animateCollection(.hide)
        }
    }
}





