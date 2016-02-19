//
//  WebViewController.swift
//  OAuthHack
//
//  Created by Daniel O'Rorke on 2/17/16.
//  Copyright © 2016 Aerohive Networks. All rights reserved.
//
//  Special thanks to Renjie (Rodger) Weng for the idea.
//

import UIKit
import Alamofire
import SwiftyJSON

class WebViewController: UIViewController, UIWebViewDelegate { //Be sure you set UIWebView Delegate!!
    
    // MARK: Variables for OAuth
    let clientID = "52739d49"
    let clientSecret = "069881278521632ab86c6ed946629dd1"
    let redirectURL = "https://developer.aerohive.com/"

    @IBOutlet weak var myWebView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        createLoginWebView()
    }
    
    func createLoginWebView() {
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
        // 'hasPrefix' checks if one string begins with the other. It returns True or False
        if (requestedURL!.lowercaseString.hasPrefix(redirectURL.lowercaseString)){
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
    
    
    
    
    // This function will exchange an AuthCode for an Access Token
    func getAccessTokenFromAuthCode(var params: [String:String]) -> [String: String] {
        print("Trying to exhange the Auth Code for an Access Token...")
        let headers = [
            "X-AH-API-CLIENT-SECRET": clientSecret,
            "X-AH-API-CLIENT-ID": clientID,
            "X-AH-API-CLIENT-REDIRECT-URI": redirectURL
        ]
        let url = "https://cloud.aerohive.com/services/acct/thirdparty/accesstoken?authCode="
        let requestURL = url
        params["redirectUri"] = redirectURL // Add the redirect URL to our query parameters.
        Alamofire.request(.POST, requestURL, headers: headers, parameters:params )
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
                    if result["error"]["status"].stringValue == "200"{
                        print("Success!")
                    }
                    else{
                        print("There was an error:" + result["error"]["status"].stringValue)
                        // TODO: NOTIFY THE USER THAT THE API RETURNED AN ERROR (404,401,403,500, etc.)
                        let alert = UIAlertController()
                        alert.title = "Hey! Error: " + result["error"]["status"].stringValue
                        alert.message = result["error"]["message"].stringValue
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            NSLog("OK Pressed")
                            self.createLoginWebView()
                        }
                        alert.addAction(okAction)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    print (result)
                }
                dispatch_async(dispatch_get_main_queue()) {
                    // Here's where we synch back up with the UI.
                    
                }
        }
        return ["hello":"there"]
    }
    
    
    // This function returns a dictionary of the query parameters from the query parmeters in any URL.
    func parametersFromQueryString(queryString: String?) -> [String: String] {
        var parameters = [String: String]()
        if (queryString != nil) {
            let parameterScanner: NSScanner = NSScanner(string: queryString!)
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
                    //parameters[name!.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!]  // iOS 8
                    parameters[name!.stringByRemovingPercentEncoding!] // iOS 9+
                        //= value!.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding) // iOS 8
                        = value!.stringByRemovingPercentEncoding // iOS 9+
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
