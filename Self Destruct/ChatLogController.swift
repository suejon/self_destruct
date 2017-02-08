//
//  ChatLogController.swift
//  Self Destruct
//
//  Created by Jono Sue on 18/01/17.
//  Copyright © 2017 Remote Hamster. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    
    var messages = [String: Message]()
    var messageKeys = [String]()
    let cellId = "cellId"
    
    override func viewDidLoad(){
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        collectionView?.contentInset = UIEdgeInsetsMake(8, 0, 8, 0)
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.alwaysBounceVertical = true
    }
    
    lazy var inputContainerView: ChatInputContainerView = {
        let chatInputContainerView = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        chatInputContainerView.chatLogController = self
        return chatInputContainerView
    }()
    
    override var inputAccessoryView: UIView {
        get {
            return inputContainerView
        }
    }

    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    func sendMessage() {
        let properties = ["text": inputContainerView.inputTextField.text!]
        sendMessageWithProperties(properties: properties as [String: AnyObject])
    }
    
    func observeMessages() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid, let toId = user?.id else {
            return
        }
        
        let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(uid).child(toId)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messageRef = FIRDatabase.database().reference().child("messages").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
//                self.messages.append(Message(dictionary: dictionary))
                let message = Message(dictionary: dictionary)
                if let msgId = message.id {
                    self.messages[msgId] = message
                    self.messageKeys.append(msgId)
                }
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                }
            })
        })
        
        userMessagesRef.observe(.childRemoved, with: { (snapshot) in
            self.messages.removeValue(forKey: snapshot.key)
            if let index = self.messageKeys.index(of: snapshot.key) {
                self.messageKeys.remove(at: index)
            }
            self.collectionView?.reloadData()
        })
    }
    
    func beginTimer(messageCell: ChatMessageCell) {
        
        messageCell.timeBombView.isHidden = true
        messageCell.activityIndicator.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            messageCell.activityIndicator.stopAnimating()
            
            // Delete from database
            if let message = messageCell.message {
                guard let uid = FIRAuth.auth()?.currentUser?.uid else {
                    return
                }
                // Remove from the messages pool
                FIRDatabase.database().reference().child("messages").child(message.id!).removeValue(completionBlock: { (error, ref) in
                    if error != nil {
                        print("Failed to delete message from messages pool:", error!)
                        return
                    }
                    self.messages.removeValue(forKey: message.id!)
                    if let index = self.messageKeys.index(of: message.id!) {
                        self.messageKeys.remove(at: index)
                    }

                    self.collectionView?.reloadData()
                })
                let userMessagesRef = FIRDatabase.database().reference().child("user-messages")
                // Remove from current
                userMessagesRef.child(uid).child(message.chatPartnerId()!).child(message.id!).removeValue(completionBlock: { (error, ref) in
                    if error != nil {
                        print("Failed to delete message in sender pool:", error!)
                        return
                    }
                })
                
                // Remove from the other
                userMessagesRef.child(message.chatPartnerId()!).child(uid).child(message.id!).removeValue(completionBlock: { (error, ref) in
                    if error != nil {
                        print("Failed to delete message in receiver pool:", error!)
                        return
                    }
                })
                
            }
        }
    }
    
    // MARK: - Private Functions
    
    private func sendMessageWithProperties(properties: [String: AnyObject]) {
        let ref = FIRDatabase.database().reference().child("messages")
        let messageRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = FIRAuth.auth()?.currentUser?.uid
        let timestamp: Int = Int(NSDate().timeIntervalSince1970)
        var values: [String: AnyObject] = ["id": messageRef.key as AnyObject, "toId": toId as AnyObject, "fromId": fromId as AnyObject, "timestamp": timestamp as AnyObject]
        
        properties.forEach({ values[$0] = $1})
        
        messageRef.updateChildValues(values) { (error, reference) in
            if error != nil {
                print(error!)
            }
            
            let userMessageRef = FIRDatabase.database().reference().child("user-messages").child(fromId!).child(toId)
            
            let messageId = messageRef.key
            userMessageRef.updateChildValues([messageId: 1])
            
            let recipientUserMessageRef = FIRDatabase.database().reference().child("user-messages").child(toId).child(fromId!)
            recipientUserMessageRef.updateChildValues([messageId: 1])
        }
        inputContainerView.inputTextField.text = nil
    }
    
    private func estimateFrame(forText: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: forText).boundingRect(with: size, options: options, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    private func setupCell(cell: ChatMessageCell, message: Message) {
        if let profileImageUrl = self.user?.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWith(urlString: profileImageUrl)
        }
        cell.timeBombView.isHidden = false
        if message.fromId == FIRAuth.auth()?.currentUser?.uid {
            cell.profileImageView.isHidden = true
            cell.bubbleView.backgroundColor = ChatMessageCell.Moss
            cell.textView.textColor = .white
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            
            cell.activityIndicatorLeftAnchor?.isActive = false
            cell.activityIndicatorRightAnchor?.isActive = true
        } else {
            cell.profileImageView.isHidden = false
            cell.bubbleView.backgroundColor = .lightGray
            cell.textView.textColor = .black
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            
            cell.activityIndicatorLeftAnchor?.isActive = true
            cell.activityIndicatorRightAnchor?.isActive = false
        }
        
    }
    
    // MARK: - collectionView functions
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        let key = messageKeys[indexPath.row]
        if let message = messages[key] {
            cell.message = message
            
            cell.chatLogController = self
            setupCell(cell: cell, message: message)
            
            if let text = message.text {
                cell.textView.text = text
                cell.bubbleViewWidthAnchor?.constant = estimateFrame(forText: text).width + 32
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        let key = messageKeys[indexPath.row]
        if let message = messages[key] {
            if let text = message.text {
                height = estimateFrame(forText: text).height + 20
            }

        }
        
        
        let width = UIScreen.main.bounds.width
        
        return CGSize(width: width, height: height)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
}
