//
//  UserCell.swift
//  Self Destruct
//
//  Created by Jono Sue on 4/01/17.
//  Copyright © 2017 Remote Hamster. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    // MARK: - Properties
    var message: Message? {
        didSet {
            if let seconds = message?.timestamp?.doubleValue {
                timeLabel.text = formatDate(seconds: seconds)
            }
            loadNameAndProfileImage()
        }
    }

    let profileImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.layer.cornerRadius = 17
        imageview.layer.masksToBounds = true
        imageview.contentMode = .scaleAspectFill
        imageview.translatesAutoresizingMaskIntoConstraints = false
        return imageview
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(timeLabel)
        
        // Constraints
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 70).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: textLabel!.heightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private functions
    
    private func loadNameAndProfileImage() {
        if let id = message?.chatPartnerId() {
            let ref = FIRDatabase.database().reference().child("users").child(id)
            ref.observe(.value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.textLabel?.text = dictionary["name"] as? String
                    
                    if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                        self.profileImageView.loadImageUsingCacheWith(urlString: profileImageUrl)
                    }
                }
            })
        }
    }
    
    private func formatDate(seconds: Double) -> String {
//        let date = NSDate(timeIntervalSince1970: date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let date = dateFormatter.string(from: Date(timeIntervalSince1970: seconds))
        return date
    }
}
