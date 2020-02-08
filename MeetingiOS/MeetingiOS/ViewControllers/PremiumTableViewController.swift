//
//  PremiumTableTableViewController.swift
//  MeetingiOS
//
//  Created by Bernardo Nunes on 03/02/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

import UIKit

class PremiumTableViewController: UITableViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var continueBtn: UIButton!
    private let store = StoreManager.shared
    var loadingView : UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(removeLoading), name: Notification.Name(rawValue: "loadingPremiun"), object: nil)
        
        loadingView = self.addInitialLoadingView(frame: self.navigationController!.view.frame)
        self.navigationController?.view.addSubview(loadingView)
        self.continueBtn.setupCornerRadiusShadow()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Table view settings

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
    
      // MARK: - IBAction
    @IBAction func didPressContinue(_ sender: Any) {
        guard let product = store.selectedProduct else { return }
        store.purchaseProduct(productId: product.productIdentifier)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didPressCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func removeLoading() {
        UIView.animate(withDuration: 1, animations: { 
            self.loadingView.alpha = 0
        }) { (_) in
            self.loadingView.removeFromSuperview()
        }
        
    }
}
