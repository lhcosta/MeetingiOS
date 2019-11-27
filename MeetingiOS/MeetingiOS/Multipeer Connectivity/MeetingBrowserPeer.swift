//
//  MeetingConnectionPeer.swift
//  MeetingiOS
//
//  Created by Lucas Costa  on 26/11/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import UIKit
import MultipeerConnectivity

/// Conexão Multipeer 
class MeetingBrowserPeer: NSObject {
    
    //MARK:- Properties
    
    /// Sessão para conexão entre os peers
    private var session : MCSession!
    
    /// Nome do tipo do serviço fornecido
    private let serviceType = "screen-meeting"
    
    /// Classe para realizar a procura de peers próximos
    private var serviceBrowser : MCNearbyServiceBrowser!

    /// Identificação do Peer
    private var peer : MCPeerID!
    
    //MARK:- Initializer
    override init() {
        super.init()
        
        self.peer = MCPeerID(displayName: UIDevice.current.name)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: self.peer, serviceType: serviceType)
        self.serviceBrowser.delegate = self
        self.session = MCSession(peer: self.peer, securityIdentity: nil, encryptionPreference: .required)
        
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    /// Data para ser enviado para o outro peer
    /// - Parameters:
    ///   - data: dados a serem enviados
    ///   - completionHandler: possíveis erros que podem acontecer
    func sendMeetingForPeer(data : Data, completionHandler: (Error?) -> Void) {
       
        do {
            try self.session.send(data, toPeers: self.session.connectedPeers, with: .reliable)
            completionHandler(nil)
        } catch let error {
            completionHandler(error)
        }        
    }
    
}

//MARK:- MCNearbyServiceBrowser
extension MeetingBrowserPeer : MCNearbyServiceBrowserDelegate {
        
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        
        self.serviceBrowser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 30)
        NSLog("%@", "Connection with - \(peerID)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "Lost connection - \(peerID)")
    }
    
}


