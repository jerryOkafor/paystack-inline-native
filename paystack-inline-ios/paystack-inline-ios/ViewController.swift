//
//  ViewController.swift
//  PaystackInline
//
//  Created by Jerry Hanks on 17/11/2019.
//  Copyright © 2019 Jerry. All rights reserved.
//

import UIKit
import WebKit

enum ScriptMessageHandler:String {
    case cancelPaymentHandler = "cancelPaymentHandler"
    case transactionResponse
}

enum VerificationState:Int{
    case verifying = 0
    case success
    case failed
}

class ViewController: UIViewController {
    
    private var paystackTestKey = "paystack_key".localized(bundle: .main, tableName: "PaystackKey")
    private let email = "example@gmail.com"
    private let amount = 20_000
    private let ref = UUID().uuidString
    
    
    private var webView:WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Paystack Inline"
        // Do any additional setup after loading the view.
        
        configureWebView()

    }


    private func configureWebView(){
        let contentController = WKUserContentController()
        //we shall add some more code here
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        self.webView = WKWebView( frame: self.view.bounds, configuration: config)
        self.view.addSubview(self.webView)
        
        let webViewContraints = [
            webView.leftAnchor.constraint(equalTo: view.leftAnchor),
            webView.rightAnchor.constraint(equalTo: view.rightAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(webViewContraints)
        
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        
//        let request = URLRequest(url: URL(string: "https://google.com")!)
//        webView.load(request)
        
        let htmlString = """
                             <!DOCTYPE html>
                             <html>

                             <head>
                                 <!--Let browser know website is optimized for mobile-->
                                 <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                                 <script src="https://js.paystack.co/v1/inline.js"></script>
                                 <script>
                                     function payWithPaystack() {
                                         var handler = PaystackPop.setup({
                                             key: '\(self.paystackTestKey)', //put your public key here
                                             email: '\(self.email)', //put your customer's email here
                                             amount: '\(self.amount)', //amount the customer is supposed to pay
                                             currency: "NGN",
                                             ref: '\(self.ref)',
                                             metadata: {
                                                 custom_fields: [
                                                     {
                                                         display_name: "Mobile Number",
                                                         variable_name: "mobile_number",
                                                         value: "+2348012345678" //customer's mobile number
                                                     }
                                                 ]
                                             },
                                             callback: function (response) {
                                                 //after the transaction have been completed
                                                 //make post call  to the server with to verify payment
                                                 //using transaction reference as post data
                                             
                                             },
                                             onClose: function () {
                                                 //when the user close the payment modal
                                                 alert('Transaction cancelled');
                                                 
                                             }
                                         });
                                         handler.openIframe(); //open the paystack's payment modal
                                     }

                                 </script>
                             </head>

                             <body onload="payWithPaystack()">
                             </body>

                             </html>
                             """
               webView.loadHTMLString(htmlString, baseURL: nil)
    }
}


//MARK: WebView UIDelegate
extension ViewController : WKUIDelegate{}

//MARK: WebView navigation Delegate
extension ViewController : WKNavigationDelegate{}

//MARK: Webview WKMessageHandler
extension ViewController: WKScriptMessageHandler{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        switch ScriptMessageHandler(rawValue: message.name)! {
        case .cancelPaymentHandler:
            self.dismiss(animated: true, completion: nil)
            break
        case .transactionResponse:
            guard let dict = message.body as? [String:AnyObject],
                let reference = dict["ref"] as? String else {return}
            
            print("Paystack Payment done with ref: \(reference)")
            
            break
        }
    }
    
    
}


extension String {
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
    }
}
