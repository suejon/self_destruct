//
//  LoginView.swift
//  Self Destruct
//
//  Created by Jono Sue on 31/12/16.
//  Copyright © 2016 Remote Hamster. All rights reserved.
//

import UIKit

class LoginView: UIView {
    
    // MARK: - Colors
    static let LightGrey: UIColor = UIColor(r: 220, g: 220, b: 220)
    static let Moss: UIColor = UIColor(r: 169, g: 177, b: 143)
    
    // MARK: - Properties
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "lock")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let loginRegisterSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.tintColor = .white
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    let inputContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let usernameTextfield: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let usernameSeparator: UIView = {
        let line = UIView()
        line.backgroundColor = LoginView.LightGrey
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    let emailTextfield: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let emailSeparator: UIView = {
        let line = UIView()
        line.backgroundColor = LoginView.LightGrey
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    let passwordTextfield: UITextField = {
        let tf = UITextField()
        tf.isSecureTextEntry = true
        tf.placeholder = "Password"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.backgroundColor = UIColor(r: 200, g: 205, b: 183)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = LoginView.Moss
        
        addSubview(inputContainer)
        addSubview(loginRegisterButton)
        addSubview(loginRegisterSegmentedControl)
        addSubview(profileImageView)
        
        inputContainer.addSubview(usernameTextfield)
        inputContainer.addSubview(usernameSeparator)
        inputContainer.addSubview(emailTextfield)
        inputContainer.addSubview(emailSeparator)
        inputContainer.addSubview(passwordTextfield)
        
        setupConstraints()
    }
    
    var inputContainerHeightAnchorConstraint: NSLayoutConstraint?
    var usernameTextfieldHeightAnchorConstraint: NSLayoutConstraint?
    var emailTextfieldHeightAnchorConstraint: NSLayoutConstraint?
    var passwordTextfieldHeightAnchorConstraint: NSLayoutConstraint?
    
    func setupConstraints() {
        // Constraints
        profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -8).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 120).isActive = true

        
        inputContainer.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        inputContainer.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        inputContainer.widthAnchor.constraint(equalTo: widthAnchor, constant: -24).isActive = true
        inputContainerHeightAnchorConstraint = inputContainer.heightAnchor.constraint(equalToConstant: 150)
        inputContainerHeightAnchorConstraint?.isActive = true
        
        usernameTextfield.leftAnchor.constraint(equalTo: inputContainer.leftAnchor, constant: 8).isActive = true
        usernameTextfield.topAnchor.constraint(equalTo: inputContainer.topAnchor).isActive = true
        usernameTextfield.widthAnchor.constraint(equalTo: inputContainer.widthAnchor).isActive = true
        usernameTextfieldHeightAnchorConstraint = usernameTextfield.heightAnchor.constraint(equalTo: inputContainer.heightAnchor, multiplier: 1/3)
        usernameTextfieldHeightAnchorConstraint?.isActive = true
        
        usernameSeparator.leftAnchor.constraint(equalTo: inputContainer.leftAnchor).isActive = true
        usernameSeparator.topAnchor.constraint(equalTo: usernameTextfield.bottomAnchor).isActive = true
        usernameSeparator.widthAnchor.constraint(equalTo: inputContainer.widthAnchor).isActive = true
        usernameSeparator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        emailTextfield.leftAnchor.constraint(equalTo: inputContainer.leftAnchor, constant: 8).isActive = true
        emailTextfield.topAnchor.constraint(equalTo: usernameTextfield.bottomAnchor).isActive = true
        emailTextfield.widthAnchor.constraint(equalTo: inputContainer.widthAnchor).isActive = true
        emailTextfieldHeightAnchorConstraint = emailTextfield.heightAnchor.constraint(equalTo: inputContainer.heightAnchor, multiplier: 1/3)
        emailTextfieldHeightAnchorConstraint?.isActive = true
        
        emailSeparator.leftAnchor.constraint(equalTo: inputContainer.leftAnchor).isActive = true
        emailSeparator.topAnchor.constraint(equalTo: emailTextfield.bottomAnchor).isActive = true
        emailSeparator.widthAnchor.constraint(equalTo: inputContainer.widthAnchor).isActive = true
        emailSeparator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        passwordTextfield.leftAnchor.constraint(equalTo: inputContainer.leftAnchor, constant: 8).isActive = true
        passwordTextfield.topAnchor.constraint(equalTo: emailTextfield.bottomAnchor).isActive = true
        passwordTextfield.widthAnchor.constraint(equalTo: inputContainer.widthAnchor).isActive = true
        passwordTextfieldHeightAnchorConstraint = passwordTextfield.heightAnchor.constraint(equalTo: inputContainer.heightAnchor, multiplier: 1/3)
        passwordTextfieldHeightAnchorConstraint?.isActive = true
        
        loginRegisterButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputContainer.bottomAnchor, constant: 8).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputContainer.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputContainer.topAnchor, constant: -8).isActive = true
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputContainer.widthAnchor).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
    }
    
    func handleLoginRegisterChange() {
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            inputContainerHeightAnchorConstraint?.constant = 100
            
            usernameTextfieldHeightAnchorConstraint?.isActive = false
            usernameTextfieldHeightAnchorConstraint = usernameTextfield.heightAnchor.constraint(equalTo: inputContainer.heightAnchor, multiplier: 0)
            usernameTextfieldHeightAnchorConstraint?.isActive = true
            usernameTextfield.isHidden = true
            
            emailTextfieldHeightAnchorConstraint?.isActive = false
            emailTextfieldHeightAnchorConstraint = emailTextfield.heightAnchor.constraint(equalTo: inputContainer.heightAnchor, multiplier: 1/2)
            emailTextfieldHeightAnchorConstraint?.isActive = true
            
            passwordTextfieldHeightAnchorConstraint?.isActive = false
            passwordTextfieldHeightAnchorConstraint = passwordTextfield.heightAnchor.constraint(equalTo: inputContainer.heightAnchor, multiplier: 1/2)
            passwordTextfieldHeightAnchorConstraint?.isActive = true
            
        } else {
            inputContainerHeightAnchorConstraint?.constant = 150
            
            usernameTextfieldHeightAnchorConstraint?.isActive = false
            usernameTextfieldHeightAnchorConstraint = usernameTextfield.heightAnchor.constraint(equalTo: inputContainer.heightAnchor, multiplier: 1/3)
            usernameTextfieldHeightAnchorConstraint?.isActive = true
            usernameTextfield.isHidden = false
            
            emailTextfieldHeightAnchorConstraint?.isActive = false
            emailTextfieldHeightAnchorConstraint = emailTextfield.heightAnchor.constraint(equalTo: inputContainer.heightAnchor, multiplier: 1/3)
            emailTextfieldHeightAnchorConstraint?.isActive = true
            
            passwordTextfieldHeightAnchorConstraint?.isActive = false
            passwordTextfieldHeightAnchorConstraint = passwordTextfield.heightAnchor.constraint(equalTo: inputContainer.heightAnchor, multiplier: 1/3)
            passwordTextfieldHeightAnchorConstraint?.isActive = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
