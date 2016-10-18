//
//  ChatViewController.swift
//  GoChat
//
//  Created by JooEun,Ahn on 2016. 10. 13..
//  Copyright © 2016년 AhnJoo-Eun. All rights reserved.
//

import UIKit
import AVKit
import JSQMessagesViewController
import MobileCoreServices
import FirebaseDatabase

class ChatViewController: JSQMessagesViewController {
    var messages = [JSQMessage]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.senderId = "1"
        self.senderDisplayName = "june"
        // Do any additional setup after loading the view.
        let rootRef = FIRDatabase.database().reference()
        let messageRef = rootRef.child("messages")
        print(rootRef)
        print(messageRef)
    
        //  messageRef.childByAutoId().setValue("Test_1")
        //  messageRef.childByAutoId().setValue("Test-2")
        messageRef.observeEventType(FIRDataEventType.Value) {(snapshot: FIRDataSnapshot) in
            print(snapshot.value)
            if let dict = snapshot.value as? NSDictionary {
                print(dict)
            }
        }
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        print("didPressSendButton")
        print("\(text)")
        print(senderId)
        print(senderDisplayName)
        messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
        collectionView.reloadData()
        print(messages)
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        print("didPressAccessoryButton")
        let sheet = UIAlertController(title: "Media Message", message: "Please select a media", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {(alert:UIAlertAction) in
        }
        
        let photoLibrary = UIAlertAction(title: "Photo Libary", style: UIAlertActionStyle.Default) { (alert: UIAlertAction) in
            self.getMediaFrom(kUTTypeImage)
        }
        let videoLibrary = UIAlertAction(title: "Video Libary", style: UIAlertActionStyle.Default) { (alert: UIAlertAction) in
            self.getMediaFrom(kUTTypeMovie)
        }
        
        sheet.addAction(photoLibrary)
        sheet.addAction(videoLibrary)
        sheet.addAction(cancel)
        self.presentViewController(sheet, animated: true, completion: nil)
//        let imagePicker = UIImagePickerController()
//        imagePicker.delegate = self
//        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func getMediaFrom(type: CFString) {
        let mediaPicker = UIImagePickerController()
        mediaPicker.delegate = self
        mediaPicker.mediaTypes = [type as String]
        self.presentViewController(mediaPicker, animated: true, completion: nil)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        return bubbleFactory.outgoingMessagesBubbleImageWithColor(.blackColor())
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("number of message \(messages.count)")
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        print("didTapMessageBubbleAtIndexPath \(indexPath.item)")
        let message = messages[indexPath.item]
        if message.isMediaMessage {
            if let mediaItem = message.media as? JSQVideoMediaItem{
                let player = AVPlayer(URL: mediaItem.fileURL)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.presentViewController(playerViewController, animated: true, completion: nil)
            }
        }
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

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("did finish picking")
        // get the image
        print(info)
        if let picture = info[UIImagePickerControllerOriginalImage] as? UIImage{
        let photo = JSQPhotoMediaItem(image: picture)
        messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: photo))
        } else if let video = info[UIImagePickerControllerMediaURL] as? NSURL {
            let videoItem = JSQVideoMediaItem(fileURL: video, isReadyToPlay: true)
            messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: videoItem))
        }
        self.dismissViewControllerAnimated(true, completion: nil)
        collectionView.reloadData()
    }
}
