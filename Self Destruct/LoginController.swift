//
//  LoginController.swift
//  Self Destruct
//
//  Created by Jono Sue on 31/12/16.
//  Copyright © 2016 Remote Hamster. All rights reserved.
//

import UIKit

class LoginController: UIViewController, UITextFieldDelegate {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return UIStatusBarStyle.lightContent
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.green
        setupView()
    }
    
    func setupView() {
        let loginView = LoginView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        view = loginView
        loginView.usernameTextfield.delegate = self
        loginView.usernameTextfield.tag = 0
        loginView.emailTextfield.delegate = self
        loginView.emailTextfield.tag = 1
        loginView.passwordTextfield.delegate = self
        loginView.passwordTextfield.tag = 2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextTextField.becomeFirstResponder()
        } else {
        textField.resignFirstResponder()
        }
        return true
    }
    
}
