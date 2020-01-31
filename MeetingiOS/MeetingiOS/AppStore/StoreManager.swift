//
//  StoreManager.swift
//  MeetingiOS
//
//  Created by Bernardo Nunes on 28/01/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

import Foundation
import StoreKit

class StoreManager: NSObject {
    
    static let shared = StoreManager()
    private override init() {}
    
    //MARK:- Properties
    var products = [SKProduct]()
    let paymentQueue = SKPaymentQueue.default()
    
    //MARK:- Methods
    /// Método que realiza o resquest dos produtos cadastrados na app store
    func getProducts() {
        let meetingsProducts = MeetingsProducts.init()
        let products: Set = [meetingsProducts.month, meetingsProducts.threeMonths, meetingsProducts.year]
        
        let request = SKProductsRequest(productIdentifiers: products)
        request.delegate = self
        request.start()
    
        paymentQueue.add(self)
    }
    
    /// Método que realiza a compra do produto
    /// - Parameter productId: ID do produto cadastrado na App Store
    func purchaseProduct(productId: String){
        guard let productToPurchase = products.filter({$0.productIdentifier == productId}).first else { return }
        
        let payment = SKPayment(product: productToPurchase)
        paymentQueue.add(payment)
    }
    
    func getReceipts() {
        let bundle = Bundle.main
        if let url = bundle.appStoreReceiptURL {
            if let receiptData = try? Data(contentsOf: url) {
                
            }
        }
    }
    
    /// Método para restaurar status de assinatura do usuário
    func restoreSubscription(){
        paymentQueue.restoreCompletedTransactions()
    }
}

//MARK:- Product request delegate
extension StoreManager: SKProductsRequestDelegate{
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
    }
}

//MARK:- Payment transaction observer
extension StoreManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                break
            default:
                queue.finishTransaction(transaction)
            }
        }
    }
}


