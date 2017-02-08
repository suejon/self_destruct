//
//  NewMessageController.swift
//  Self Destruct
//
//  Created by Jono Sue on 4/01/17.
//  Copyright © 2017 Remote Hamster. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class NewMessageController: UITableViewController {
    
    var users = [User]()
    let cellId = "cellId"
    var messagesController: MessagesController?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleCancel))
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        fetchUsers()
    }
    
    func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func fetchUsers() {
        // Fetch all users from Firebase and fill the users array
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User()
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.profileImageUrl = dictionary["profileImageUrl"] as? String
                user.id = snapshot.key
                
                if user.id != FIRAuth.auth()?.currentUser?.uid {
                    self.users.append(user)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }, withCancel: nil)
    }

    // MARK: - overridden functions
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        if let profileImageUrl = user.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWith(urlString: profileImageUrl)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) { 
            let user = self.users[indexPath.row]
            self.messagesController?.showChatControllerFor(user: user)
        }
    }

}
