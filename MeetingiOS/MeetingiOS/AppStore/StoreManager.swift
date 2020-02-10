//
//  StoreManager.swift
//  MeetingiOS
//
//  Created by Bernardo Nunes on 28/01/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

import Foundation
import StoreKit

@objc class StoreManager: NSObject {
    
    @objc static let shared = StoreManager()
    private override init() {}
    
    //MARK:- Properties
    var products = [SKProduct]()
    private let paymentQueue = SKPaymentQueue.default()
    weak var delegate: StoreManagerDelegate?
    var selectedProduct: SKProduct?
    #if DEBUG
    private let verifyReceiptURL = "https://sandbox.itunes.apple.com/verifyReceipt"
    #else
    private let verifyReceiptURL = "https://buy.itunes.apple.com/verifyReceipt"
    #endif
    
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
    func purchaseProduct(productId: String) {
        
        guard let productToPurchase = products.filter({$0.productIdentifier == productId}).first else { return }
        
        let payment = SKPayment(product: productToPurchase)
        paymentQueue.add(payment)
        
    }
    
    /// Método para restaurar status de assinatura do usuário
    func restoreSubscription(){
        paymentQueue.restoreCompletedTransactions()
    }
    
    @objc func receiptValidation(completionHandler: @escaping (_ receipt: Date?) -> Void){
        
        guard let receiptUrl = Bundle.main.appStoreReceiptURL  else {
            completionHandler(nil)
            return
        }
        
        guard let purchaseReceipt = try? Data(contentsOf: receiptUrl) else { return completionHandler(nil) }
        self.validatePurchaseReceipt(pReceiptData: purchaseReceipt){ data in
            completionHandler(data)
        }
    }
    
    
    private func validatePurchaseReceipt(pReceiptData: Data, completion: @escaping (Date?) -> Void){
        let base64encodedReceipt = pReceiptData.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
        let requestReceiptDict: [String: Any] = ["receipt": base64encodedReceipt, "url": verifyReceiptURL]
        
        guard JSONSerialization.isValidJSONObject(requestReceiptDict) else { return completion(nil)}
        do {
            let data = try JSONSerialization.data(withJSONObject: requestReceiptDict, options: .prettyPrinted)
            
            let validationString = "https://meetings-iap-verifier.herokuapp.com/receipt"
            
            guard let validationUrl = URL(string: validationString) else { return completion(nil) }
            let session = URLSession(configuration: .default)
            var request = URLRequest(url: validationUrl, cachePolicy: .reloadIgnoringLocalCacheData)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = session.uploadTask(with:request, from: data) { (data, response, error) in
                guard let data = data, error == nil else {return}
                do {
                    let purchaseReceiptJSON = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let result = self.getExpirationDateFromResponse((purchaseReceiptJSON as? NSDictionary)!)
                    //guard let final = result else { return completion(nil)}
                    completion(result)
                } catch let error {
                    completion(nil)
                    print("Aqui \(error)")
                }
            }
            task.resume()
        } catch let error {
            print(error)
        }
        
    }
    
    private func getExpirationDateFromResponse(_ jsonResponse: NSDictionary) -> Date? {
        
        if let receiptInfo: NSArray = jsonResponse["latest_receipt_info"] as? NSArray {
            
            let lastReceipt = receiptInfo.lastObject as! NSDictionary
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
            
            if let expirationDate = lastReceipt["expires_date"] as? String {
                if let date = formatter.date(from: expirationDate){
                    
                    var addOneHour = date.timeIntervalSinceNow
                    addOneHour += (60*60)
                    let newDate = Date(timeIntervalSinceNow: addOneHour)
                    
                    return newDate
                }
            }
            
            return nil
        }
        else {
            return nil
        }
        
    }
    
}

//MARK:- Product request delegate
extension StoreManager: SKProductsRequestDelegate{
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
        self.delegate?.storeManagerDidReceiveResponse()
        
        print(response.invalidProductIdentifiers)
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

//MARK:- Extension SKProduct to get local price
extension SKProduct {
    fileprivate static var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }
    
    var localizedPrice: String {
        if self.price == 0.00 {
            return "Get"
        } else {
            let formatter = SKProduct.formatter
            formatter.locale = self.priceLocale
            
            guard let formattedPrice = formatter.string(from: self.price) else {
                return "Unknown Price"
            }
            
            return formattedPrice
        }
    }
}
