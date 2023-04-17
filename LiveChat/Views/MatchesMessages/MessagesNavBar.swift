//
//  MessagesNavBar.swift
//  LiveChat
//
//  Created by Hakan Körhasan on 16.04.2023.
//

import LBTATools
import UIKit
import SDWebImage

class MessagesNavBar: UIView {
    
    let userProfileImageView = UIImageView(image: #imageLiteral(resourceName: "jane2"), contentMode: .scaleAspectFill)
    
    let nameLabel = UILabel(text: "Kelly", font: .systemFont(ofSize: 16))
    
    let backButton = UIButton(image: #imageLiteral(resourceName: "back").withRenderingMode(.alwaysTemplate), tintColor: #colorLiteral(red: 0.978428781, green: 0.3918142915, blue: 0.5514227152, alpha: 1))
    
    let flagButton = UIButton(image: #imageLiteral(resourceName: "flag").withRenderingMode(.alwaysTemplate), tintColor: #colorLiteral(red: 0.978428781, green: 0.3918142915, blue: 0.5514227152, alpha: 1))
    
    fileprivate let match: Match
    
    init(match: Match) {
        self.match = match
        super.init(frame: .zero)
        backgroundColor = .white
        
        setupShadow(opacity: 0.2, radius: 8, offset: .init(width: 0, height: 10), color: .init(white: 0, alpha: 0.3))
        
        userProfileImageView.constrainWidth(55)
        userProfileImageView.constrainHeight(55)
        userProfileImageView.clipsToBounds = true
        userProfileImageView.layer.cornerRadius = 55 / 2
        
        self.nameLabel.text = match.name
        
        let url = URL(string: match.profileImageUrl)
        
        userProfileImageView.sd_setImage(with: url)
        
        stack(
            hstack(backButton,
                   stack(userProfileImageView, nameLabel, spacing: 8, alignment: .center),
                   flagButton, alignment: .center).withMargins(.init(top: 0, left: 20, bottom: 0, right: 20)))

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
