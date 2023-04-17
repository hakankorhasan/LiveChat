//
//  Advertiser.swift
//  LiveChat
//
//  Created by Hakan Körhasan on 22.12.2022.
//

import UIKit

struct Advertiser: ProducesCardViewModel {
    
    let title: String
    let brandName: String
    let posterPhotoName: String
    
    func toCardViewModel() -> CardViewModel {
        
        let attributedText = NSMutableAttributedString(string: title,
                                                       attributes: [.font: UIFont.systemFont(ofSize: 32, weight: .heavy)])
        attributedText.append(NSMutableAttributedString(string: "\n", attributes: [.font: UIFont.systemFont(ofSize: 24, weight: .bold)]))
        
        return CardViewModel(uid: "" ,imageNames: [posterPhotoName], attributedString: attributedText, textAlignment: .center)
    }
    
}
