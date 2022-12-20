//
//  TopNavigationStackView.swift
//  LiveChat
//
//  Created by Hakan Körhasan on 20.12.2022.
//

import UIKit

class TopNavigationStackView: UIStackView {

    let settingsButton = UIButton(type: .system)
    let messageButton = UIButton(type: .system)
    let fireImageView = UIImageView(image: #imageLiteral(resourceName: "app_icon"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        heightAnchor.constraint(equalToConstant: 80).isActive = true
        fireImageView.contentMode = .scaleAspectFit
        
        settingsButton.setImage(UIImage(imageLiteralResourceName: "top_left_profile").withRenderingMode(.alwaysOriginal), for: .normal)

        messageButton.setImage(UIImage(imageLiteralResourceName: "top_right_messages").withRenderingMode(.alwaysOriginal), for: .normal)
        
        [settingsButton, UIView(), fireImageView, UIView(), messageButton].forEach { (button) in
            addArrangedSubview(button)
        }
        
        distribution = .equalCentering
    }
    
    required init(coder: NSCoder) {
        fatalError()
    }

}
