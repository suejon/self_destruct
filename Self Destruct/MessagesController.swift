//
//  ViewController.swift
//  Self Destruct
//
//  Created by Jono Sue on 31/12/16.
//  Copyright © 2016 Remote Hamster. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class MessagesController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
    }
    
    
    func handleLogout() {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginController()
        loginController.messagesController = self
//        print("Successfully signed out")
        present(loginController, animated: true, completion: nil)
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let userId = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
    }
    


}

