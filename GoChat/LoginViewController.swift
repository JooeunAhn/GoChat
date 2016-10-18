//
//  LoginViewController.swift
//  GoChat
//
//  Created by JooEun,Ahn on 2016. 10. 13..
//  Copyright © 2016년 AhnJoo-Eun. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseAuth

class LoginViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {

    @IBOutlet weak var anonymousButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //  anonymousButton
        //  Set border color
        anonymousButton.layer.borderWidth = 2.0
        anonymousButton.layer.borderColor = UIColor.whiteColor().CGColor
        GIDSignIn.sharedInstance().clientID = "13431354186-kmfhhg2ducva7mm6d258jrcstmvnd2fu.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print(FIRAuth.auth()?.currentUser)
        
        FIRAuth.auth()?.addAuthStateDidChangeListener({ (auth: FIRAuth, user: FIRUser?) in
            if user != nil {
                print(user)
                Helper.helper.switchToNavigationViewController()
            }else {
                print("Unauthorized")
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginAnonymouslyDidTapped(sender: AnyObject) {
        print("login anonymously did tapped")
        //  Anonymously log users in
        //  switch view by setting navigation controller as root view controller
        Helper.helper.loginAnonymously()
    }

    @IBAction func googleLoginDidTapped(sender: AnyObject) {
        
        GIDSignIn.sharedInstance().signIn()
    }
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        if error != nil{
            print(error!.localizedDescription)
            return
        }
        print(user.authentication)
        Helper.helper.loginWithGoogle(user.authentication)

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
