//
//  Helper.swift
//  GoChat
//
//  Created by JooEun,Ahn on 2016. 10. 14..
//  Copyright © 2016년 AhnJoo-Eun. All rights reserved.
//

import Foundation
import FirebaseAuth
import UIKit
import GoogleSignIn

//로그인 한번만 가능하게, 뷰 옮길 때.. 쓰는 헬퍼
class Helper {
    static let helper = Helper()
    func loginAnonymously() {
        print("login anonymously did tapped")
        //  Anonymously log users in
        //  switch view by setting navigation controller as root view controller
        
        FIRAuth.auth()?.signInAnonymouslyWithCompletion({   ( anonymousUser: FIRUser?, error: NSError?) in
            if error == nil {
                print("UserId: \(anonymousUser!.uid)")
                
                self.switchToNavigationViewController()
                
            } else {
                print(error!.localizedDescription)
                return
            }
        })
    }
    func loginWithGoogle(authentication: GIDAuthentication){
        
        let credential = FIRGoogleAuthProvider.credentialWithIDToken(authentication.idToken, accessToken: authentication.accessToken)
        FIRAuth.auth()?.signInWithCredential(credential, completion: { (user:FIRUser?, error: NSError?) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }else{
                print(user?.email)
                print(user?.displayName)
                self.switchToNavigationViewController()
                }
            })
        
        }
    
    private func switchToNavigationViewController(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let naviVC = storyboard.instantiateViewControllerWithIdentifier("NavigationVC")as! UINavigationController
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController = naviVC
    }

}