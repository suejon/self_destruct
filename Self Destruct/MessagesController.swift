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
    
    // MARK: - Properties
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    var timer: Timer?
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "newMessage"), style: .plain, target: self, action: #selector(handleNewMessage))
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        tableView.allowsMultipleSelectionDuringEditing = true
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
        // Empty the old messages to prevent any previous log in data from being shown
        messagesDictionary = [String: Message]()
        self.tableView.reloadData()
        // load messages
        observeUserMessages()
        
        let profileImageView: UIImageView = {
            let imageview = UIImageView()
            imageview.contentMode = .scaleAspectFit
            imageview.translatesAutoresizingMaskIntoConstraints = false
            imageview.layer.cornerRadius = 15
            imageview.clipsToBounds = true
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

    // Any changes that occur to the database are observed when the view gets loaded and the messages
    // are updated accordingly
    func observeUserMessages() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let currentUserMessages = FIRDatabase.database().reference().child("user-messages").child(uid)
        
        currentUserMessages.observe(.childAdded, with: { (snapshot) in
            
            let userId = snapshot.key
            FIRDatabase.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                let messageId = snapshot.key
                self.fetchMessageWith(messageId: messageId)
            })
            
        })
        
        currentUserMessages.observe(.childRemoved, with: { (snapshot) in
            self.messagesDictionary.removeValue(forKey: snapshot.key)
            self.attemptReloadOfTable()
        })
        
    }
    
    // MARK: - Private Functions
    
    private func fetchMessageWith(messageId: String) {
        let messageRef = FIRDatabase.database().reference().child("messages").child(messageId)
        
        messageRef.observe(.value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message(dictionary: dictionary)
                
                if let chatPartnerId = message.chatPartnerId() {
                    self.messagesDictionary[chatPartnerId] = message
                }
                self.attemptReloadOfTable()
            }
        })
    }
    
    private func attemptReloadOfTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.handleReload), userInfo: nil, repeats: false)
    }
    
    func handleReload() {
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort { (m1, m2) -> Bool in
            return m1.timestamp!.intValue > m2.timestamp!.intValue
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - TableView Functions
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            
            // Create user object for the chat partner
            let user = User()
            user.name = dictionary["name"] as? String
            user.email = dictionary["email"] as? String
            user.profileImageUrl = dictionary["profileImageUrl"] as? String
            user.id = chatPartnerId
            
            self.showChatControllerFor(user: user)
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let message = messages[indexPath.row]
        cell.message = message
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    // The two following methods, along with setting allowsMultipleSelection to true, handles deletion
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        let message = self.messages[indexPath.row]
        
        if let chatPartnerId = message.chatPartnerId() {
            FIRDatabase.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue(completionBlock: { (error, ref) in
                
                if error != nil {
                    print("Failed to delete message:", error!)
                    return
                }
                self.messagesDictionary.removeValue(forKey: chatPartnerId)
                self.attemptReloadOfTable()
                
            })
        }
    }
}

