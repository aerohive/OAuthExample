//
//  WebViewController.swift
//  OAuthHack
//
//  Created by Daniel O'Rorke on 2/17/16.
//  Copyright © 2016 Aerohive Networks. All rights reserved.
//
//  Special thanks to Renjie (Rodger) Wang for the idea.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate { //Be sure you set UIWebView Delegate!!
    
    // MARK: Variables for OAuth
    let clientID = "52739d49"
    let clientSecret = "069881278521632ab86c6ed946629dd1"
    let redirectURL = "https://developer.aerohive.com"

    @IBOutlet weak var myWebView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    //======= THIS GENERATES THE WEBVIEW WHEN USERS LOG IN=========

        
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
        let requestedURL = myWebView.request?.URL?.absoluteString
        print (requestedURL)
        
        //Check if the request URL contains our redirect URL
        // 'lowercaseString' converts both strings to lowercase so it is case agnostic
        // 'rangeOfString' checks if one string is contained in the other. It returns nil if it does not match.
        if (requestedURL!.lowercaseString.rangeOfString(redirectURL.lowercaseString) != nil){
            print("Found your auth code!")
            let UrlArray = requestedURL!.componentsSeparatedByString("?") //Split the URL string into an array on '?'
            let queryString = UrlArray[1] // Grab only the things after the '?'
            let params = parametersFromQueryString(queryString) //We get back a dict of the query params.
            print(params)
        }
        
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
    
    
    // This function returns a dictionary of the query parameters from the query parmeters in the URL.
    func parametersFromQueryString(queryString: String?) -> [String: String] {
        var parameters = [String: String]()
        if (queryString != nil) {
            var parameterScanner: NSScanner = NSScanner(string: queryString!)
            var name:NSString? = nil
            var value:NSString? = nil
            while (parameterScanner.atEnd != true) {
                name = nil;
                parameterScanner.scanUpToString("=", intoString: &name)
                parameterScanner.scanString("=", intoString:nil)
                value = nil
                parameterScanner.scanUpToString("&", intoString:&value)
                parameterScanner.scanString("&", intoString:nil)
                if (name != nil && value != nil) {
                    parameters[name!.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!]
                        = value!.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
                }
            }
        }
        return parameters
    }
    
    // This function extracts the AUTH CODE from the URL paramters using paramertsFromQueryString()
    func extractCode(notification: NSNotification) -> String? {
        let url: NSURL? = (notification.userInfo as!
            [String: AnyObject])[UIApplicationLaunchOptionsURLKey] as? NSURL
        
        // [1] extract the code from the URL
        return self.parametersFromQueryString(url?.query)["code"]
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
