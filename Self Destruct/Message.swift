//
//  Message.swift
//  Self Destruct
//
//  Created by Jono Sue on 20/01/17.
//  Copyright © 2017 Remote Hamster. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    var fromId: String?
    var toId: String?
    var text: String?
    var timestamp: NSNumber?
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        fromId = dictionary["fromId"] as? String
        toId = dictionary["toId"] as? String
        text = dictionary["text"] as? String
        timestamp = dictionary["timestamp"] as? NSNumber
    }
    
    // To find out who is the chat partner, check if the message's fromId matches the current logged in user.
    // If it does, the chat partner has the toId Id. Otherwise the current user is the recipient and has the toId
    func chatPartnerId() -> String? {
        if fromId == FIRAuth.auth()?.currentUser?.uid {
            return toId
        } else {
            return fromId
        }
        
    }
}
