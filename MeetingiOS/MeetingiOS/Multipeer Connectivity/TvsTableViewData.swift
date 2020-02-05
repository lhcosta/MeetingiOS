//
//  TvsTableViewData.swift
//  MeetingiOS
//
//  Created by Lucas Costa  on 31/01/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

import UIKit
import MultipeerConnectivity

/// Model da Table View de TVs
class TvsTableViewData: NSObject {

    weak var tableView : TvsTableView!
    private var tvs : [MCPeerID] = []
    
    init(_ tableView : TvsTableView) {
        super.init()
        
        self.tableView = tableView
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.backgroundColor = .black
        self.tableView.alpha = 0.6
        
    }

}

//MARK:- TableViewDataSource
extension TvsTableViewData : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tvs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TvCell", for: indexPath) as! TvTableViewCell
        cell.tvName.text = tvs[indexPath.row].displayName
        
        return cell
    }
}

//MARK:- TableViewDelegate
extension TvsTableViewData : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SelectedTV"), object: self.tvs[indexPath.row], userInfo: nil)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let title = UILabel()
        let image = UIImageView()
        let stackView = UIStackView(arrangedSubviews: [image, title])
        
        view.backgroundColor = .black
        
        title.text = "Apple TVs"
        title.textAlignment = .center
        title.textColor = .white
        title.font = UIFont(name: "SFProText-Bold", size: 12)
        
        image.image = UIImage(systemName: "rectangle.on.rectangle")
        image.tintColor = .white
        
        title.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        stackView.spacing = 5
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            image.widthAnchor.constraint(equalToConstant: 30),
            image.heightAnchor.constraint(equalToConstant: 20)
        ])
                
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
}


//MARK:- TvsTableViewConfig
extension TvsTableViewData : FindTvsDelegate {
    
    func sendNewTV(peerID: MCPeerID) {
        self.tvs.append(peerID)
        self.tableView.insertRows(at: [IndexPath(row: tvs.count - 1, section: 0)], with: .fade)
    }    
    
    func removeTV(peerID: MCPeerID) {
        
        if let index = self.tvs.firstIndex(where: {
            $0 == peerID
        }) {
            self.tvs.remove(at: index)
            self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
}
