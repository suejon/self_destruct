//
//  ViewController.swift
//  Self Destruct
//
//  Created by Jono Sue on 31/12/16.
//  Copyright © 2016 Remote Hamster. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Messages Controller"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
    }
    
    
    func handleLogout() {
        present(LoginController(), animated: true, completion: nil)
    }

    


}

