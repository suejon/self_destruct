//
//  ChatMessageCell.swift
//  Self Destruct
//
//  Created by Jono Sue on 30/01/17.
//  Copyright © 2017 Remote Hamster. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
    static let Moss: UIColor = UIColor(r: 169, g: 177, b: 143)
    var chatLogController: ChatLogController?
    var message: Message?
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.textColor = .white
        tv.backgroundColor = .clear
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isEditable = false
        return tv
    }()
    
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = ChatMessageCell.Moss
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.layer.cornerRadius = 16
        imageview.clipsToBounds = true
        imageview.translatesAutoresizingMaskIntoConstraints = false
        imageview.contentMode = .scaleAspectFit
        return imageview
    }()
    
    
    var bubbleViewWidthAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        
        // Constraints
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        bubbleViewWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleViewWidthAnchor?.isActive = true
        
        // All bubbles are by default placed on the right side
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubbleViewRightAnchor?.isActive = true
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
