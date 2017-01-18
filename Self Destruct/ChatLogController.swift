//
//  ChatLogController.swift
//  Self Destruct
//
//  Created by Jono Sue on 18/01/17.
//  Copyright © 2017 Remote Hamster. All rights reserved.
//

import UIKit

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
        
    }
}
