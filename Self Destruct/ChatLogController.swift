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
    
    var messages = [Message]()
    let cellId = "cellId"
    
    override func viewDidLoad(){
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
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
                
                self.messages.append(Message(dictionary: dictionary))
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                }
            })
        })
    }
    
    // MARK: - Private Functions
    
    private func sendMessageWithProperties(properties: [String: AnyObject]) {
        let ref = FIRDatabase.database().reference().child("messages")
        let messageRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = FIRAuth.auth()?.currentUser?.uid
        let timestamp: Int = Int(NSDate().timeIntervalSince1970)
        var values: [String: AnyObject] = ["toId": toId as AnyObject, "fromId": fromId as AnyObject, "timestamp": timestamp as AnyObject]
        
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
        if message.fromId == FIRAuth.auth()?.currentUser?.uid {
            cell.profileImageView.isHidden = true
            cell.bubbleView.backgroundColor = ChatMessageCell.Moss
            cell.textView.textColor = .white
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        } else {
            cell.profileImageView.isHidden = false
            cell.bubbleView.backgroundColor = .lightGray
            cell.textView.textColor = .black
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
        
    }
    
    // MARK: - collectionView functions
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        let message = messages[indexPath.row]
        cell.chatLogController = self

        setupCell(cell: cell, message: message)
        
        if let text = message.text {
            cell.textView.text = text
            cell.bubbleViewWidthAnchor?.constant = estimateFrame(forText: text).width + 32
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        let message = messages[indexPath.row]
        
        if let text = message.text {
            height = estimateFrame(forText: text).height + 20
        }
        
        let width = UIScreen.main.bounds.width
        
        return CGSize(width: width, height: height)
    }
    
}
