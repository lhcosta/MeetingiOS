//
//  SelectionTVsViewController.swift
//  MeetingiOS
//
//  Created by Lucas Costa  on 07/02/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class SelectionTVsViewController: UIViewController {
    
    //MARK:- Properties
    private var tvsTableView : TvsTableView!
    private var tvsTableViewData : TvsTableViewData!
    var meeting : Meeting!
    private var multipeer : MeetingBrowserPeer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(dissmissViewController), name: Notification.Name("sendMeeting"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(selectedTv(notification:)), name: Notification.Name(rawValue:"SelectedTV"), object: nil)
        
        self.tvsTableView = TvsTableView()
        self.tvsTableViewData = TvsTableViewData(tvsTableView)
        
        view.addSubview(tvsTableView)
        
        NSLayoutConstraint.activate([
            tvsTableView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3),
            tvsTableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tvsTableView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        if self.traitCollection.horizontalSizeClass == .regular {
            tvsTableView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.6).isActive = true
        } else {
            tvsTableView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
        }
        
        tvsTableView.awakeFromNib()
        tvsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        self.multipeer = MeetingBrowserPeer(tvsTableViewData)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// Recebendo o peer selecionado através de uma notificação enviada.
    /// - Parameter notification: notificacao enviada.
    @objc private func selectedTv(notification : NSNotification) {
        
        guard let peerId = notification.object as? MCPeerID else {return}
        
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(self.meeting) {
            self.multipeer?.sendInviteFromPeer(peerID: peerId, dataToSend: data)
        }
    }   
    
    @objc private func dissmissViewController() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }   
    }
}
