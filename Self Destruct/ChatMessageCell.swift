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
        tv.font = UIFont.systemFont(ofSize: 16)
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
        imageview.layer.masksToBounds = true
        imageview.translatesAutoresizingMaskIntoConstraints = false
        imageview.contentMode = .scaleAspectFit
        return imageview
    }()
    
    lazy var timeBombView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let effectView = UIVisualEffectView(effect: blurEffect)
        
//        effectView.frame = self.bubbleView.frame
//        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        effectView.translatesAutoresizingMaskIntoConstraints = false
        effectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(beginTimer)))
        effectView.isUserInteractionEnabled = true
        
        return effectView
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    var bubbleViewWidthAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    
    var activityIndicatorLeftAnchor: NSLayoutConstraint?
    var activityIndicatorRightAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        addSubview(timeBombView)
        addSubview(activityIndicator)
        
        // Constraints
        
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        bubbleViewWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleViewWidthAnchor?.priority = 999
        bubbleViewWidthAnchor?.isActive = true
        
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubbleViewRightAnchor?.isActive = true
        
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
    
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true

        timeBombView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        timeBombView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        timeBombView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        timeBombView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor).isActive = true
        
        activityIndicator.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicator.heightAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true

        activityIndicatorLeftAnchor = activityIndicator.leftAnchor.constraint(equalTo: bubbleView.rightAnchor)
        activityIndicatorRightAnchor = activityIndicator.rightAnchor.constraint(equalTo: bubbleView.leftAnchor)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func beginTimer() {
        timeBombView.isHidden = true
        self.activityIndicator.startAnimating()
        print("Begin timer")
    }
}
