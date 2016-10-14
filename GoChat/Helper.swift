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
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let naviVC = storyboard.instantiateViewControllerWithIdentifier("NavigationVC")as! UINavigationController
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.window?.rootViewController = naviVC
                
            } else {
                print(error!.localizedDescription)
                return
            }
        })
        
        
    }

}