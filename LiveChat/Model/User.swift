//
//  User.swift
//  LiveChat
//
//  Created by Hakan Körhasan on 21.12.2022.
//

import UIKit

struct User {
    
    let name: String
    let age: Int
    let profession: String
    let imageName: String
    
    
    // her seferinde kullanmamak için generic bir yapı kurduk
    //bu yapı üzerinden görüntüleme yapacağız
    func toCardViewModel() -> CardViewModel {
        
        let attributedText = NSMutableAttributedString(string: name, attributes: [.font: UIFont.systemFont(ofSize: 32, weight: .heavy)])
        
        attributedText.append(NSMutableAttributedString(string: "  \(age)", attributes: [.font: UIFont.systemFont(ofSize: 24, weight: .regular)]))
        
        attributedText.append(NSMutableAttributedString(string: "\n\(profession)", attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .regular)]))
        
        return CardViewModel(imageName: imageName, attributedString: attributedText, textAlignment: .left)
    }
    
}


