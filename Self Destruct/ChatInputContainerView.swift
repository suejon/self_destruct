//
//  ChatInputContainerView.swift
//  Self Destruct
//
//  Created by Jono Sue on 18/01/17.
//  Copyright © 2017 Remote Hamster. All rights reserved.
//

import UIKit

class ChatInputContainerView: UIView, UITextFieldDelegate {
    
    // MARK: - Properties
    
    var chatLogController: ChatLogController?
    
    lazy var inputTextField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .white
        tf.placeholder = "Enter text here"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.delegate = self
        return tf
    }()
    
    let separator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        return view
    }()
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubview(sendButton)
        addSubview(inputTextField)
        addSubview(separator)
        
        // Constraints
        
        separator.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        separator.bottomAnchor.constraint(equalTo: self.topAnchor).isActive = true
        separator.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        sendButton.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        sendButton.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        inputTextField.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        chatLogController?.sendMessage()
        return true
    }
}
