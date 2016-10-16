//
//  ChatViewController.swift
//  GoChat
//
//  Created by JooEun,Ahn on 2016. 10. 13..
//  Copyright © 2016년 AhnJoo-Eun. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {
    var messages = [JSQMessage]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.senderId = "1"
        self.senderDisplayName = "june"
        // Do any additional setup after loading the view.
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        print("didPressSendButton")
        print("\(text)")
        print(senderId)
        print(senderDisplayName)
        messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
        print(messages)
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        print("didPressAccessoryButton")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutDidTapped(sender: AnyObject) {
        //  Create a main storyboard instance
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        //  From main storyboard instantiate a navigation controller
        let LoginVC = storyboard.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
        //  Get the app delegate
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //  Set Login view Controller as root view controller
        appDelegate.window?.rootViewController = LoginVC
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
