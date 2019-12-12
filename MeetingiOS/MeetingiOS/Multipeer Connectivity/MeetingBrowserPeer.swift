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
    
    //Data para ser enviado através dos peers
    private var data : Data!
    
    //MARK:- Initializer
    override init() {
        super.init()
        
        self.peer = MCPeerID(displayName: UIDevice.current.name)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: self.peer, serviceType: serviceType)
        self.serviceBrowser.delegate = self
        self.session = MCSession(peer: self.peer, securityIdentity: nil, encryptionPreference: .required)
        self.session.delegate = self
    }

    /// Data para ser enviado para o outro peer
    /// - Parameters:
    ///   - data: dados a serem enviados
    ///   - completionHandler: possíveis erros que podem acontecer
    private func sendMeetingForPeer(data : Data, completionHandler: @escaping (Error?) -> Void) {
       
        do {
            try self.session.send(data, toPeers: self.session.connectedPeers, with: .reliable)
            completionHandler(nil)
        } catch let error {
            completionHandler(error)
        }        
    }
    
    
    /// Dados a serem enviados para o peer
    /// - Parameter data: data
    func sendingDataFromPeer(data : Data) {
        self.data = data
        self.serviceBrowser.startBrowsingForPeers()        
    }
    
    /// Parar a busca de peers.
    func stoppingBrowserPeer() {
        self.serviceBrowser.stopBrowsingForPeers()
        NSLog("%@", "Stop Browser peer")
    }
    
}

//MARK:- MCNearbyServiceBrowser
extension MeetingBrowserPeer : MCNearbyServiceBrowserDelegate {

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "Did not start connection - \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        self.serviceBrowser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
        NSLog("%@", "Connection with - \(peerID)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "Lost connection - \(peerID)")
    }
    
}

extension MeetingBrowserPeer : MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
            case .connected:
                self.sendMeetingForPeer(data: data) { (error) in
                    if let error = error {
                        print("Error - > \(error)")
                    }
            }
            
                self.stoppingBrowserPeer()
            case .notConnected:
                NSLog("%@", "Did not connect")
                self.serviceBrowser.startBrowsingForPeers()
                break
            default:
            break
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        //
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        //
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        //
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        //
    }
    
    
    
    
}

