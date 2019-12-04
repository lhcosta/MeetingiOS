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
    private var contactsStore : CNContactStore!
    private var contacts : [Character : [Contact]] = [:]
    private var sortedContacts : [(key : Character, value : [Contact])] = []
    private var filteringContacts : [Contact] = []
    private var contactCollectionView : ContactCollectionView?
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
