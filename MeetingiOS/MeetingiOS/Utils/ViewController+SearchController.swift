//
//  ViewController+SearchController.swift
//  MeetingiOS
//
//  Created by Bernardo Nunes on 11/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    /// Método que implementa search bar com scope bar se necessário
    /// - Parameter segmentedControlTitles: titulos de cada scope (passe nil caso não queira scope bar)
    func setUpSearchBar(segmentedControlTitles: [String]?){
        
        let search = UISearchController(searchResultsController: nil)
        search.hidesNavigationBarDuringPresentation = false
        search.obscuresBackgroundDuringPresentation = false
        
        search.searchResultsUpdater = self as? UISearchResultsUpdating
        
        if let titles = segmentedControlTitles, titles.count>0 {
            search.searchBar.scopeButtonTitles = titles
            search.searchBar.showsScopeBar = true
        }
        
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.searchController = search

        definesPresentationContext = true
    }
}
