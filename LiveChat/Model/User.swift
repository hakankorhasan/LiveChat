//
//  User.swift
//  LiveChat
//
//  Created by Hakan Körhasan on 21.12.2022.
//

import UIKit

struct User: ProducesCardViewModel {
    
    var name: String?
    var age: Int?
    var profession: String?
    var bio: String?
    var imageUrl1: String?
    var imageUrl2: String?
    var imageUrl3: String?
    var minSeekingAge: Int?
    var maxSeekingAge: Int?
    var uid: String?
    
    // controllerde göstermeyi sağladık
    init(dictionary: [String : Any]) {
        self.name = dictionary["fullName"] as? String ?? ""
        self.age = dictionary["age"] as? Int
        self.profession = dictionary["profession"] as? String ?? ""
        self.bio = dictionary["bio"] as? String ?? ""
        self.imageUrl1 = dictionary["imageUrl1"] as? String
        self.imageUrl2 = dictionary["imageUrl2"] as? String
        self.imageUrl3 = dictionary["imageUrl3"] as? String
        self.minSeekingAge = dictionary["minSeekingAge"] as? Int
        self.maxSeekingAge = dictionary["maxSeekingAge"] as? Int
        self.uid = dictionary["uid"] as? String ?? ""
    }
    
    // her seferinde kullanmamak için generic bir yapı kurduk
    //bu yapı üzerinden görüntüleme yapacağız
    func toCardViewModel() -> CardViewModel {
        
        let ageString = age != nil ? "\(age!)" : "N\\A"
        let professionString = profession != nil ? "\(profession!)" : "Not Available"
        
        let attributedText = NSMutableAttributedString(string: name ?? "", attributes: [.font: UIFont.systemFont(ofSize: 32, weight: .heavy)])
        
        attributedText.append(NSMutableAttributedString(string: "  \(ageString)", attributes: [.font: UIFont.systemFont(ofSize: 24, weight: .regular)]))
        
        attributedText.append(NSMutableAttributedString(string: "\n\(professionString)", attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .regular)]))
        
        var imageUrls = [String]()
        if let url = imageUrl1 { imageUrls.append(url) }
        if let url = imageUrl2 { imageUrls.append(url) }
        if let url = imageUrl3 { imageUrls.append(url) }
        
        return CardViewModel(uid: self.uid ?? "" ,imageNames: imageUrls, attributedString: attributedText, textAlignment: .left)
    }
    
}


