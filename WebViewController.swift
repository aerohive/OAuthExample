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

    // This function is called every time the view finishes loading...
    func webViewDidFinishLoad(webView : UIWebView) {
        print("Finished!")
        let requestedURL = myWebView.request?.URL?.absoluteString
        print (requestedURL)
        
        //Check if the request URL contains our redirect URL
        // 'lowercaseString' converts both strings to lowercase so it is case agnostic
        // 'rangeOfString' checks if one string is contained in the other. It returns nil if it does not match.
        if (requestedURL!.lowercaseString.rangeOfString(redirectURL.lowercaseString) != nil){
            print ("Spotted the Redirect URL!")
            let UrlArray = requestedURL!.componentsSeparatedByString("?") //Split the URL string into an array on '?'
            let queryString = UrlArray[1] // Grab only the things after the '?'
            let params = parametersFromQueryString(queryString) // We get back a dict of the query params.
            print(params)
            if params["authCode"] != nil { // Check if the result has authCode
                print("Found your auth code!")
                let accessTokensJSON = getAccessTokenFromAuthCode(params)
            }
            else { // We don't have the Auth Code
                // ADD NOTIFICATION TO USER HERE
                print ("There was an error.")
            }
        }
        
    }
    func webViewDidStartLoad(webView: UIWebView) {
        let requestedURL = myWebView.request?.URL?.absoluteString
        print("STARTED" + requestedURL!)
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
    
    // This function will exchange an AuthCode for an Access Token
    func getAccessTokenFromAuthCode(params: [String:String]) -> [String: String] {
        print("Trying to exhange the Auth Code for an Access Token...")
        let headers = [
            "X-AH-API-CLIENT-SECRET": clientSecret,
            "X-AH-API-CLIENT-ID": clientID,
            "X-AH-API-CLIENT-REDIRECT-URI": redirectURL
        ]
        let url = "https://cloud.aerohive.com/services/acct/thirdparty/accesstoken?authCode=" + params["authCode"]! + "&redirectUri=" + redirectURL
        let requestURL = url
        // let params = ["ownerID": ownerID] //Use this to better set up query parameters.
        Alamofire.request(.GET, requestURL, headers: headers /* ,parameters:params */)
            .responseJSON { response in
                // Check that the error is nil
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling GET on "+requestURL)
                    print(response.result.error!)
                    print("Headers: ")
                    print(headers)
                    return
                }
                print("Parsed JSON")
                if let value: AnyObject = response.result.value {
                    // handle the results as JSON, without a bunch of nested if loops
                    let result = JSON(value)
                }
                dispatch_async(dispatch_get_main_queue()) {
                    // Here's where we synch back up with the UI.
                    
                }
        }
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
