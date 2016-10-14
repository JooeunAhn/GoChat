//
//  LoginViewController.swift
//  GoChat
//
//  Created by JooEun,Ahn on 2016. 10. 13..
//  Copyright © 2016년 AhnJoo-Eun. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var anonymousButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //  anonymousButton
        //  Set border color
        anonymousButton.layer.borderWidth = 2.0
        anonymousButton.layer.borderColor = UIColor.whiteColor().CGColor
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginAnonymouslyDidTapped(sender: AnyObject) {
        print("login anonymously did tapped")
        //  Anonymously log users in
        //  switch view by setting navigation controller as root view controller
        
        //  Create a main storyboard instance
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        //  From main storyboard instantiate a navigation controller
        let naviVC = storyboard.instantiateViewControllerWithIdentifier("NavigationVC")as! UINavigationController
        //  Get the app delegate
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //  Set Navigation Controller as root view controller
        appDelegate.window?.rootViewController = naviVC
    }

    @IBAction func googleLoginDidTapped(sender: AnyObject) {
        //  Create a main storyboard instance
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        //  From main storyboard instantiate a navigation controller
        let naviVC = storyboard.instantiateViewControllerWithIdentifier("NavigationVC")as! UINavigationController
        //  Get the app delegate
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //  Set Navigation Controller as root view controller
        appDelegate.window?.rootViewController = naviVC
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
