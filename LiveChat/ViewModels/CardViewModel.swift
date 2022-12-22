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
    let imageNames: [String]
    let attributedString: NSAttributedString
    let textAlignment: NSTextAlignment
    
    init(imageNames: [String], attributedString: NSAttributedString, textAlignment: NSTextAlignment) {
        self.imageNames = imageNames
        self.attributedString = attributedString
        self.textAlignment = textAlignment
    }
    
    fileprivate var imageIndex = 0 {
        didSet{
            let imageName = imageNames[imageIndex]
            let image = UIImage(named: imageName)
            imageIndexObserver?(imageIndex, image)
        }
    }
    
    
    //Reactive Programming
    var imageIndexObserver: ((Int, UIImage?) -> ())?
    
    func advanceNextPhoto(){
        imageIndex = min(imageIndex + 1, imageNames.count - 1)
    }
    
    func goToPreviousPhoto(){
        imageIndex = max(0, imageIndex - 1)
    }
    
}
