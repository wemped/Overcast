//
//  ViewController.swift
//  spotify-sdk-test
//
//  Created by Drake Wempe on 9/7/15.
//  Copyright © 2015 Drake Wempe. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, SPTAudioStreamingPlaybackDelegate {
    let ClientID = "eca84f057c5e43f7a990d771752d2885"
    let CallBackURL = "spotifysdktest://returnafterlogin"
    /*You will need to change these for testing on localhost or your own phone!*/
    /*Also needs to change in AppDelegate*/
    let TokenSwapURL = "http://192.168.1.160/swap"
    let TokenRefreshServiceURL = "http://192.168.1.160:1234/refresh"
    let RailsServerUrl = "http://192.168.1.9:3000"
    var session: SPTSession!
    var sentPassword : String?
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var registerLabel: UILabel!
    @IBOutlet weak var spotifyLoginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    /*
    Check if we have an Overcast Login
        If not unhide the registration stuff
        If we do call checkSpotifyAccount
    */
    override func viewDidLoad() {
        print("loaded")
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateAfterFirstLogin", name: "loginSuccesful", object: nil)
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        /*FOR TESTING ONLY - DELETE AFTER*/
        self.checkSpotifyAccount()
        /* ----------------------------- */
        //Hide everything
        spotifyLoginButton.hidden = true
        registerLabel.hidden = true
        usernameTextField.hidden = true
        passwordTextField.hidden = true
        confirmPasswordTextField.hidden = true
        registerButton.hidden = true
        //Check if we have Overcast username and password saved on user preferences
//        let username = userDefaults.stringForKey("OvercastUsername")
//        let password = userDefaults.stringForKey("OvercastPassword")
//        if username != nil && password != nil {
//            self.checkSpotifyAccount()
//        }else{
//            //show registration stuff
//            registerLabel.hidden = false
//            usernameTextField.hidden = false
//            passwordTextField.hidden = false
//            confirmPasswordTextField.hidden = false
//            registerButton.hidden = false
//        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Spotify in Browser functions
    /*
        Called from the Browser
        Get newly set session from User Defaults
        Segue to Home
    */
    func updateAfterFirstLogin (){
        spotifyLoginButton.hidden = true
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let sessionObj:AnyObject = userDefaults.objectForKey("SpotifySession"){
            let sessionDataObj = sessionObj as! NSData
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObjectWithData(sessionDataObj) as! SPTSession
            self.session = firstTimeSession
            self.segueToMainScreen()
        }
    }
    
    //MARK: - UIButton handlers
    /*
        Overcast registration button
        Creates a user on postgres if valid username and password
    */
    @IBAction func registerButtonPressed(sender: UIButton) {
        let username = self.usernameTextField.text
        let password = self.passwordTextField.text
        let confPassword = self.confirmPasswordTextField.text
        self.sentPassword = username
        self.loginRequest(username!, password: password!, confPassword: confPassword)
    }
    /*
        Open browser to Spotify Login page
        Spotify will call updateAfterFirstLogin when finished
    */
    @IBAction func loginWithSpotify(sender: UIButton) {
        let auth = SPTAuth.defaultInstance()
        let loginURL = auth.loginURLForClientId(ClientID, declaredRedirectURL: NSURL(string: CallBackURL), scopes: [SPTAuthStreamingScope])
        UIApplication.sharedApplication().openURL(loginURL)
    }
    
    //MARK: - HTTP send/recieve functions
    /*
        Sends a POST request with registration info to the rails server
    */
    func loginRequest(username: String, password: String, confPassword: String?){
        if let urlToReq = NSURL(string: RailsServerUrl + "/users"){
            let request = NSMutableURLRequest(URL: urlToReq)
            request.HTTPMethod = "POST"
            var bodyData = "username=\(username)"
            bodyData += "&password=\(password)"
            bodyData += "&password_confirmation=\(confPassword!)"
            request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
            NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                self.handleOvercastLoginResponse(data, response: response, error: error)
            }).resume()
        }
    }
    /*
        If login was good save the username/password in userdefaults
    */
    func handleOvercastLoginResponse(data: NSData?, response: NSURLResponse?, error: NSError?){
        do {
            if let JSONObject: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers){
                print (JSONObject!)
                if let object = JSONObject as? NSMutableArray{
                    if let user = object[0] as? NSDictionary{
                        let username = user["username"]
                        let password = self.sentPassword
                        let userDefaults = NSUserDefaults.standardUserDefaults()
                        userDefaults.setObject(username, forKey: "OvercastUsername")
                        userDefaults.setObject(password, forKey: "OvercastPassword")
                        self.checkSpotifyAccount()
                        return
                    }
                }
            }
            //HANDLE LOGIN FAILURE
        }catch{
            print("Couldn't create json object from response")
        }
    }
    /*
        Check user defaults for spotify session
        if valid try and refresh it
        if not show the Spotify Login Button
    */
    func checkSpotifyAccount(){
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let sessionObj:AnyObject = userDefaults.objectForKey("SpotifySession"){//Session available
            let sessionDataObj = sessionObj as! NSData
            let session = NSKeyedUnarchiver.unarchiveObjectWithData(sessionDataObj) as! SPTSession
            if !session.isValid() {
                SPTAuth.defaultInstance().renewSession(session, withServiceEndpointAtURL: NSURL(string: TokenRefreshServiceURL)){
                    (error: NSError!,renewedSession: SPTSession!) -> Void in
                    if error == nil {
                        let sessionData = NSKeyedArchiver.archivedDataWithRootObject(session)
                        userDefaults.setObject(sessionData, forKey: "SpotifySession")
                        userDefaults.synchronize()
                        self.session = renewedSession
                        self.segueToMainScreen()

                    }else{
                        print ("error refreshing session")
                    }
                }
            }else{
                print("session valid")
                self.session = session
                self.segueToMainScreen()
            }
        }else{
            spotifyLoginButton.hidden = false
        }

    }
    
    //MARK: - Navigation
    func segueToMainScreen(){
        dispatch_async(dispatch_get_main_queue()){
            print("segueToMainScreen")
            self.performSegueWithIdentifier("loginSuccessSegue", sender: self)
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "loginSuccessSegue" {
            let tabController = segue.destinationViewController as! TabBarController
            tabController.session = self.session
        }
    }
}

