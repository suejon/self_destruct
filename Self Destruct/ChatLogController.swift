//
//  ChatLogController.swift
//  Self Destruct
//
//  Created by Jono Sue on 18/01/17.
//  Copyright © 2017 Remote Hamster. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController {
    
    var user: User? {
        didSet {
            navigationItem.title = user?.name
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
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
    
    // MARK: - Private Functions
    
    private func sendMessageWithProperties(properties: [String: AnyObject]) {
        let ref = FIRDatabase.database().reference().child("messages")
        let messageRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = FIRAuth.auth()?.currentUser?.uid
        let timestamp: Int = Int(NSDate().timeIntervalSince1970)
        var values: [String: AnyObject] = ["toId": toId as AnyObject, "FromId": fromId as AnyObject, "timestamp": timestamp as AnyObject]
        
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
    
}
