//
//  ViewController.swift
//  Showcase
//
//  Created by Minni K Ang on 2016-06-21.
//  Copyright © 2016 CreativeIce. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class ViewController: UIViewController {

    @IBOutlet weak var emailAdd: UITextField!
    
    @IBOutlet weak var pWord: UITextField!
    
     override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
        }
    }
    
    @IBAction func fbBtnPressed(sender: UIButton!) {
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logInWithReadPermissions(["email"]) { (facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) in
            
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                print("Successfully logged in with facebook \(accessToken)")

                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
                
                FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
                
                    if error != nil {
                        print("Login failed. \(error)")
                    } else {
                        print("Logged In!\(user)")
                        let userData = ["provider": credential.provider]
                        DataService.ds.createFirebaseUser(user!.uid, user: userData)
                    
                        NSUserDefaults.standardUserDefaults().setValue(user!.uid, forKey: KEY_UID)
                        self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                }
            })
        }
    }

    }
    
    @IBAction func emailBtnPressed(sender: UIButton!) {
        if let email = emailAdd.text where email != "", let password = pWord.text where password != "" {
            
            FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) in
                    
                    if error != nil {
                        print(error)
                        
                        if error!.code == STATUS_ACCOUNT_NONEXISTENT {
                            FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (user, error) in
                                
                                if error != nil {
                                    self.showErrorAlert("Could Not Create Account", msg: "Try Something Else")
                                } else {
                                    NSUserDefaults.standardUserDefaults().setValue(user!.uid, forKey: KEY_UID)
                                    let userData = ["provider": "email"]
                                    DataService.ds.createFirebaseUser(user!.uid, user: userData)

                                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                                }
                            })
                            
                    } else {
                        self.showErrorAlert("Could Not Login", msg: "Please check your email and password")
                    }
                        
                } else {
                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                }
            })
        } else {
            self.showErrorAlert("Email and Password Required", msg: "You must enter an email and password")
        }
    }

    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }

}