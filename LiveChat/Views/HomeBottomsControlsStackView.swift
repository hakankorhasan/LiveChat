//
//  HomeBottomsControlsStackView.swift
//  LiveChat
//
//  Created by Hakan Körhasan on 20.12.2022.
//

import UIKit

class HomeBottomsControlsStackView: UIStackView {
    
    static func createButton(image: UIImage) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }
    
    let refreshButton = createButton(image: #imageLiteral(resourceName: "refresh_circle"))
    let dislikeButton = createButton(image: #imageLiteral(resourceName: "dismiss_circle"))
    let superLikeButton = createButton(image: #imageLiteral(resourceName: "super_like_circle"))
    let likeButton = createButton(image: #imageLiteral(resourceName: "like_circle"))
    let specialButton = createButton(image: #imageLiteral(resourceName: "boost_circle"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        distribution = .fillEqually
        heightAnchor.constraint(equalToConstant: 120).isActive = true
  
        // bottom row of buttons
        [refreshButton, dislikeButton, superLikeButton, likeButton, specialButton].forEach { (button) in
            self.addArrangedSubview(button)
        }
       
    }

    required init(coder: NSCoder) {
        fatalError()
    }
    
}
