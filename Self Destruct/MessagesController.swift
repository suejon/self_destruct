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
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "newMessage"), style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkIfUserIsLoggedIn()
    }
    
    func checkIfUserIsLoggedIn() {
        if FIRAuth.auth()?.currentUser?.uid == nil {
            DispatchQueue.main.async {
                self.handleLogout()
            }
        } else {
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    func handleLogout() {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginController()
        loginController.messagesController = self
        present(loginController, animated: true, completion: nil)
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let userId = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        FIRDatabase.database().reference().child("users").child(userId).observe(.value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                let user = User()
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.profileImageUrl = dictionary["profileImageUrl"] as? String
                
                self.setupNavBarWithUser(user: user)
            }
        })
    }
    
    func showChatControllerFor(user: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    func setupNavBarWithUser(user: User) {
        
        let profileImageView: UIImageView = {
            let imageview = UIImageView()
            imageview.contentMode = .scaleAspectFit
            imageview.translatesAutoresizingMaskIntoConstraints = false
            if let profileImageUrl = user.profileImageUrl {
                imageview.loadImageUsingCacheWith(urlString: profileImageUrl)
            }
            return imageview
        }()
        
        let nameLabel: UILabel = {
            let label = UILabel()
            label.text = user.name
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        let labelContainer: UIView = {
            let view = UIView()
            view.addSubview(profileImageView)
            view.addSubview(nameLabel)
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        let titleContainer: UIView = {
            let container = UIView()
            container.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
            container.addSubview(labelContainer)
            return container
        }()
        
        // Constraints
        
        profileImageView.leftAnchor.constraint(equalTo: labelContainer.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: labelContainer.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: labelContainer.rightAnchor).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: labelContainer.centerYAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        labelContainer.centerYAnchor.constraint(equalTo: titleContainer.centerYAnchor).isActive = true
        labelContainer.centerXAnchor.constraint(equalTo: titleContainer.centerXAnchor).isActive = true
        
        self.navigationItem.titleView = titleContainer
    }
    
    func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        let navigationController = UINavigationController(rootViewController: newMessageController)
        present(navigationController, animated: true, completion: nil)
    }


}

