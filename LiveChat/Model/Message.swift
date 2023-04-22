//
//  Message.swift
//  LiveChat
//
//  Created by Hakan Körhasan on 22.04.2023.
//

import UIKit
import Firebase

struct Message {
    let text, fromId, toId: String
    let timestamp: Timestamp
    
    let isCurrentLoggedUser: Bool
    
    init(dictionary: [String: Any]) {
        self.text = dictionary["text"] as? String ?? ""
        self.fromId = dictionary["fromId"] as? String ?? ""
        self.toId = dictionary["toId"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        
        self.isCurrentLoggedUser = Auth.auth().currentUser?.uid == self.fromId
    }
}
