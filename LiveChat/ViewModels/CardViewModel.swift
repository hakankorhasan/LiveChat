//
//  CardViewModel.swift
//  LiveChat
//
//  Created by Hakan Körhasan on 21.12.2022.
//

import UIKit

protocol ProducesCardViewModel {
    func toCardViewModel() -> CardViewModel
}

class CardViewModel {
    
    // cardview da gösterilecek şeyler burada tutuluyor
    let uid: String
    let imageNames: [String]
    let attributedString: NSAttributedString
    let textAlignment: NSTextAlignment
    
    init(uid: String ,imageNames: [String], attributedString: NSAttributedString, textAlignment: NSTextAlignment) {
        self.uid = uid
        self.imageNames = imageNames
        self.attributedString = attributedString
        self.textAlignment = textAlignment
    }
    
    fileprivate var imageIndex = 0 {
        didSet{
            let imageUrl = imageNames[imageIndex]
            //let image = UIImage(named: imageName)
            imageIndexObserver?(imageIndex, imageUrl)
        }
    }
    
    
    //Reactive Programming
    var imageIndexObserver: ((Int, String?) -> ())?
    
    func advanceNextPhoto(){
        imageIndex = min(imageIndex + 1, imageNames.count - 1)
    }
    
    func goToPreviousPhoto(){
        imageIndex = max(0, imageIndex - 1)
    }
    
}
