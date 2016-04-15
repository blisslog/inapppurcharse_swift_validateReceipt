//
//  PaymentViewController.swift
//  App
//
//  Created by Blisslog on 2016. 4. 14..
//  Copyright © 2016년 Blisslog. All rights reserved.
//

import UIKit
import StoreKit

class PaymentViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    var product_id: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UIButton
    @IBAction func closePayment() {
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    
    @IBAction func restorePurchase() {
        if SKPaymentQueue.canMakePayments() {
            SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
        }
        else {
            print("can't make purchases")
        }
    }
    
    @IBAction func buyConsumable() {
        if SKPaymentQueue.canMakePayments() {
            product_id = "your_consumable_product_id"
            let productID = NSSet(object: product_id!)
            let productsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
            productsRequest.delegate = self
            productsRequest.start()
        }
        else {
            print("can't make purchases")
        }
    }
    
    @IBAction func buyNonConsumable() {
        if SKPaymentQueue.canMakePayments() {
            product_id = "your_none_consumable_product_id"
            let productID = NSSet(object: product_id!)
            let productsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
            productsRequest.delegate = self
            productsRequest.start()
        }
        else {
            print("can't make purchases")
        }
        
    }
    
    func productsRequest (request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        let count : Int = response.products.count
        if count>0 {
            let validProduct = response.products[0] as SKProduct
            if validProduct.productIdentifier == self.product_id {
                print(validProduct.localizedTitle)
                print(validProduct.localizedDescription)
                print(validProduct.price)
                buyProduct(validProduct)
            }
            else {
                print(validProduct.productIdentifier)
            }
        }
        else {
            print("nothing")
        }
    }
    
    func buyProduct(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    func restoreCompletedTransactions() {
        print("restoreCompletedTransactions")
    }
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .Purchased:
                validateReceipt()
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
            case .Failed:
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
            default:
                break
            }
        }
    }
    
    /*
     https://developer.apple.com/library/ios/releasenotes/General/ValidateAppStoreReceipt/Chapters/ValidateRemotely.html
     */
    func validateReceipt() {
        //let response: NSURLResponse?
        //let error: NSError?
        
        let receiptUrl = NSBundle.mainBundle().appStoreReceiptURL
        let receipt: NSData = NSData(contentsOfURL:receiptUrl!)!
        
        let receiptdata: NSString = receipt.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        
        let requestData:NSData?
        let requestContents = ["receipt-data": receiptdata]
        
        do {
            requestData = try NSJSONSerialization.dataWithJSONObject(requestContents, options: NSJSONWritingOptions(rawValue: 0))
            if requestData == nil {
                print("err")
            }
        } catch {
            print("err")
        }
        
        //let request = NSMutableURLRequest(URL: NSURL(string: "https://buy.itunes.apple.com/verifyReceipt")!)
        let request = NSMutableURLRequest(URL: NSURL(string: "https://sandbox.itunes.apple.com/verifyReceipt")!)
        
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        request.HTTPBody = receiptdata.dataUsingEncoding(NSASCIIStringEncoding)
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
            if error != nil {
                print("Receipt Error: \(error?.description)")
            }
            else {
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
                    
                    if json == nil { /* ... Handle error ...*/ }
                    else {
                        print("Receipt \(json)")
                    }
                    
                } catch {
                    print("err")
                }
                
                /* ... Send a response back to the device ... */
            }
        })
        
        task.resume()
    }
    
    func paymentQueue(queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: NSError) {
        print("paymentQueue:restoreCompletedTransactionsFailedWithError")
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        print("paymentQueueRestoreCompletedTransactionsFinished")
        
        if queue.transactions.count == 0 {
            // none
        }
        
        for transaction in queue.transactions {
            let product_id = transaction.payment.productIdentifier
            
            if product_id == "your_none_consumable_product_id" {
                // ok already buy
                // after process
            }
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
