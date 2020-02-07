//
//  PremiumOptionsTableViewController.swift
//  MeetingiOS
//
//  Created by Bernardo Nunes on 04/02/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

import UIKit

class PremiumOptionsTableViewController: UITableViewController {
    
    // MARK: - Properties
    private let store = StoreManager.shared
    private let ids = [MeetingsProducts().month, MeetingsProducts().threeMonths, MeetingsProducts().sixMonths]
    var loadingView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showLoadingView()
        store.delegate = self
        store.getProducts()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        store.selectedProduct = nil
    }
    
    // MARK: - Methods
    private func showLoadingView() {
        loadingView = self.addInitialLoadingView()
        self.view.addSubview(loadingView!)
    }
    
    private func removeLoadingView() {
        self.loadingView?.removeFromSuperview()
    }
    
    // MARK: - Table view
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        print(store.products.count)
        return store.products.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! OptionsTableViewCell
        
        let product = store.products[indexPath.section]
        var productTitle = ""
        
        switch product.productIdentifier {
        case ids[0]:
            productTitle = NSLocalizedString("1 month", comment: "")
        case ids[1]:
            productTitle = NSLocalizedString("3 months", comment: "")
        case ids[2]:
            productTitle = NSLocalizedString("6 months", comment: "")
        default:
            print("erro")
        }
    
        cell.timeLbl.text = productTitle
        cell.priceLabel.text = product.localizedPrice
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        store.selectedProduct = store.products[indexPath.section]
    }
}

extension PremiumOptionsTableViewController: StoreManagerDelegate {
    func storeManagerDidReceiveResponse() {
        DispatchQueue.main.async {
            self.store.products.sort { (p1, p2) -> Bool in
                if p1.price.compare(p2.price) == .orderedAscending {
                    return true
                } else {
                    return false
                }
            }
            self.tableView.reloadData()
            self.removeLoadingView()
        }
    }
}
