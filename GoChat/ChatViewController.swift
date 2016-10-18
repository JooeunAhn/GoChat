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
import FirebaseStorage
import FirebaseAuth

class ChatViewController: JSQMessagesViewController {
    var messages = [JSQMessage]()
    var avatarDict = [String: JSQMessagesAvatarImage]()
    
    
    var messageRef = FIRDatabase.database().reference().child("messages")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let currentUser = FIRAuth.auth()?.currentUser{
            self.senderId = currentUser.uid
            
            if currentUser.anonymous == true{
                self.senderDisplayName = "anonymous"
            }else{
                self.senderDisplayName = "\(currentUser.displayName!)"
            }
            
        }
        
        observeMessages()
    }
    
    func observeUsers(id: String){
        
        FIRDatabase.database().reference().child("users").child(id).observeEventType(.Value, withBlock: { snapshot in
            if let dict = snapshot.value as? [String: AnyObject]{
                let avatarUrl = dict["profileUrl"] as! String
            
                self.setupAvatar(avatarUrl, messageId: id)
            }
            
        })
    }
    
    func setupAvatar(url: String, messageId: String){
        if url != "" {
            let fileUrl = NSURL(string: url)
            let data = NSData(contentsOfURL: fileUrl!)
            let image = UIImage(data: data!)
            let userImg = JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: 30)
            avatarDict[messageId] = userImg
        } else{
            
            avatarDict[messageId] = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "profileImage"), diameter: 30)
        }
        
        collectionView.reloadData()
    }
    
    func observeMessages() {
        messageRef.observeEventType(.ChildAdded, withBlock: { snapshot in
            print(snapshot.value)
            if let dict = snapshot.value as? [String: AnyObject] {
                let mediaType = dict["MediaType"] as! String
                let senderId = dict["senderId"] as! String
                let senderName = dict["senderName"] as! String
                
                self.observeUsers(senderId)
                
                switch mediaType {
                case "TEXT":
                    
                    let text = dict["text"] as! String
                    self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, text: text))
                    
                case "PHOTO":
                    
                    let fileUrl = dict["fileUrl"] as! String
                    let url = NSURL(string: fileUrl)
                    let data = NSData(contentsOfURL: url!)
                    let picture = UIImage(data: data!)
                    let photo = JSQPhotoMediaItem(image: picture)
                    self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: photo))
                    
                    if self.senderId == senderId{
                        photo.appliesMediaViewMaskAsOutgoing = true
                    }else{
                        photo.appliesMediaViewMaskAsOutgoing = false
                    }
                    
                case "VIDEO":
                    
                    let fileUrl = dict["fileUrl"] as! String
                    let video = NSURL(string: fileUrl)
                    let videoItem = JSQVideoMediaItem(fileURL: video, isReadyToPlay: true)
                    self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: videoItem))
                    
                    
                    if self.senderId == senderId{
                        videoItem.appliesMediaViewMaskAsOutgoing = true
                    }else{
                        videoItem.appliesMediaViewMaskAsOutgoing = false
                    }
                    
                default:
                    print("Unknown Data Type")
                    
                }
                self.collectionView.reloadData()
            }
        })
    }
    
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        //messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
        //collectionView.reloadData()
        //print(messages)
        
        let newMessage = messageRef.childByAutoId()
        let messageData = ["text": text, "senderId": senderId, "senderName": senderDisplayName, "MediaType": "TEXT"]
        newMessage.setValue(messageData)
        self.finishSendingMessage()
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
        
        let message = messages[indexPath.item]
        
        return avatarDict[message.senderId]
//        return JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "profileimage"), diameter: 30)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        if message.senderId == self.senderId{
            return bubbleFactory.outgoingMessagesBubbleImageWithColor(.blackColor())
        }else{
            return bubbleFactory.incomingMessagesBubbleImageWithColor(.blueColor())
        }
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
        
        do {
            try FIRAuth.auth()?.signOut()
        }catch let error {
            print(error)
        }
        
        
        //  Create a main storyboard instance
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        //  From main storyboard instantiate a navigation controller
        let LoginVC = storyboard.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
        //  Get the app delegate
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //  Set Login view Controller as root view controller
        appDelegate.window?.rootViewController = LoginVC
    }
    
    func sendMedia(picture: UIImage?, video: NSURL?){
        
        if let picture = picture {
            let filePath = "\(FIRAuth.auth()!.currentUser!)/\(NSDate.timeIntervalSinceReferenceDate())"
            //let data = UIImageJPEGRepresentation(picture!, 1)
            // 압축버젼
            let data = UIImageJPEGRepresentation(picture, 0.1)
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpg"
            FIRStorage.storage().reference().child(filePath).putData(data!, metadata: metadata){ (metadata, error) in
                if error != nil {
                    print(error)
                    return
                }else {
                    let fileUrl = metadata!.downloadURLs![0].absoluteString
                    let newMessage = self.messageRef.childByAutoId()
                    let messageData = ["fileUrl": fileUrl, "senderId": self.senderId, "senderName": self.senderDisplayName, "MediaType": "PHOTO"]
                    newMessage.setValue(messageData)
                }
                    
                }
            
        }else if let video = video{
            let filePath = "\(FIRAuth.auth()!.currentUser!)/\(NSDate.timeIntervalSinceReferenceDate())"
            //let data = UIImageJPEGRepresentation(picture!, 1)
            // 압축버젼
            let data = NSData(contentsOfURL: video)
            let metadata = FIRStorageMetadata()
            metadata.contentType = "video/mp4"
            FIRStorage.storage().reference().child(filePath).putData(data!, metadata: metadata){ (metadata, error) in
                if error != nil {
                    print(error)
                    return
                }else {
                    let fileUrl = metadata!.downloadURLs![0].absoluteString
                    let newMessage = self.messageRef.childByAutoId()
                    let messageData = ["fileUrl": fileUrl, "senderId": self.senderId, "senderName": self.senderDisplayName, "MediaType": "VIDEO"]
                    newMessage.setValue(messageData)
                }
                
            }

        }
        
    }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("did finish picking")
        // get the image
        print(info)
        if let picture = info[UIImagePickerControllerOriginalImage] as? UIImage{
            sendMedia(picture, video: nil)
        
        } else if let video = info[UIImagePickerControllerMediaURL] as? NSURL {
            
            sendMedia(nil, video: video)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
        collectionView.reloadData()
    }
}
