//
//  StoreManagerDelegate.swift
//  MeetingiOS
//
//  Created by Bernardo Nunes on 05/02/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

import Foundation
import StoreKit

protocol StoreManagerDelegate: AnyObject {
    /// Provides the delegate with the App Store's response.
    func storeManagerDidReceiveResponse()
}
