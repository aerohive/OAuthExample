//
//  WebViewController.swift
//  OAuthHack
//
//  Created by Daniel O'Rorke on 2/17/16.
//  Copyright © 2016 Aerohive Networks. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate { //Be sure you set UIWebView Delegate!!

    @IBOutlet weak var myWebView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    //======= THIS GENERATES THE WEBVIEW WHEN USERS LOG IN=========
        // MARK: Variables for OAuth
        let clientID = "52739d49"
        let clientSecret = "069881278521632ab86c6ed946629dd1"
        let redirectURL = "https://developer.aerohive.com"
        
        // Set up the OAuth URL to call
        let authQueryParams = "?client_id="+clientID+"&redirect_uri="+redirectURL
        let urlString = "https://cloud.aerohive.com/thirdpartylogin"+authQueryParams
        let url = NSURL (string: urlString)
        
        let requestObj = NSURLRequest(URL: url!);
        myWebView.delegate = self // Allows us to OVERRIDE functions
        myWebView.loadRequest(requestObj);
    //=============================================================
    }

    func webViewDidFinishLoad(webView : UIWebView) {
        print("Finished!")
        let requestedURL = myWebView.request?.URL
        print (requestedURL)
        
    }
    func webViewDidStartLoad(webView: UIWebView) {
        print("Started")
        let requestedURL = myWebView.request?.URL
        print (requestedURL)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
