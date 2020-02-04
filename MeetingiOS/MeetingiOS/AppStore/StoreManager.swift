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
        let products: Set = [meetingsProducts.month, meetingsProducts.threeMonths, meetingsProducts.sixMonths]
        
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
    
//    func receiptValidation(completionHandler: @escaping (_ receipt: Data?) -> Void){
//
//        guard let receiptUrl = Bundle.main.appStoreReceiptURL  else {
//            completionHandler(nil)
//            return
//        }
//
//        guard let purchaseReceipt = try? Data(contentsOf: receiptUrl) else { return completionHandler(nil) }
//
//        self.validatePurchaseReceipt(pReceiptData: purchaseReceipt){ data in
//            completionHandler(data)
//        }
//
//
//    }
//
//
//    func validatePurchaseReceipt(pReceiptData: Data, completion: @escaping (Receipt?) -> Void){
//        let base64encodedReceipt = pReceiptData.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
//
//        let requestReceiptDict: [String: Any] = ["receipt": base64encodedReceipt, "url": verifyReceiptURL]
//
//
//        guard JSONSerialization.isValidJSONObject(requestReceiptDict) else { return completion(nil)}
//        do {
//            let data = try JSONSerialization.data(withJSONObject: requestReceiptDict, options: .prettyPrinted)
//
//            let validationString = " https://meetings-receipt-validator.herokuapp.com/"
//
//            guard let validationUrl = URL(string: validationString) else { return completion(nil)}
//            let session = URLSession(configuration: .default)
//            var request = URLRequest(url: validationUrl, cachePolicy: .reloadIgnoringLocalCacheData)
//            request.httpMethod = "POST"
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//            let task = session.uploadTask(with:request, from: data) { (data, response, error) in
//                guard let data = data, error == nil else { return}
//                do {
//                    let purchaseReceiptJSON = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
//                    let result = self.getExpirationDateFromResponse((purchaseReceiptJSON as? NSDictionary)!)
//                    //                    guard let final = result else { return completion(nil)}
//                    completion(result)
//                } catch let error {
//                    completion(nil)
//                    print("Aqui \(error)")
//                }
//            }
//            task.resume()
//        } catch let error {
//            print(error)
//        }
//
//    }
//
//    func getExpirationDateFromResponse(_ jsonResponse: NSDictionary) -> String? {
//
//        if let receiptInfo: NSArray = jsonResponse["latest_receipt_info"] as? NSArray {
//
//            let lastReceipt = receiptInfo.lastObject as! NSDictionary
//            let formatter = DateFormatter()
//            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
//
//            if let expirationDate = lastReceipt["expires_date"] as? String {
//                return expirationDate
//
//            }
//
//            return nil
//        }
//        else {
//            return nil
//        }
//
//    }
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


