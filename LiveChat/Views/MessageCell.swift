//
//  MessageCell.swift
//  LiveChat
//
//  Created by Hakan Körhasan on 22.04.2023.
//

import LBTATools
import UIKit

class MessageCell: LBTAListCell<Message> {
    
    let textView: UITextView = {
       let tv = UITextView()
        tv.backgroundColor = .clear
        tv.font = .systemFont(ofSize: 18)
        tv.isScrollEnabled = false
        tv.isEditable = false
        return tv
    }()
    
    let bubbleView = UIView(backgroundColor: UIColor(#colorLiteral(red: 0.8054330945, green: 0.8107859492, blue: 0.8106914759, alpha: 0.8470588235)))
    
    override var item: Message! {
        didSet {
            textView.text = item.text
            
            if item.isCurrentLoggedUser {
                anchoredConstraints.leading?.isActive = false
                anchoredConstraints.trailing?.isActive = true
                bubbleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
                bubbleView.backgroundColor = #colorLiteral(red: 0.1471898854, green: 0.8059007525, blue: 0.9965714812, alpha: 1)
                textView.textColor = .white
            } else {
                anchoredConstraints.leading?.isActive = true
                anchoredConstraints.trailing?.isActive = false
                bubbleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
                bubbleView.backgroundColor = #colorLiteral(red: 0.9005706906, green: 0.9012550712, blue: 0.9006766677, alpha: 1)
                textView.textColor = .black
            }
        }
    }
    
    var anchoredConstraints: AnchoredConstraints!
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(bubbleView)
        anchoredConstraints = bubbleView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        anchoredConstraints.leading?.constant = 20
        anchoredConstraints.trailing?.isActive = false
        anchoredConstraints.trailing?.constant = -20
        
        // bu iki satır da şuanki kullanıcının yolladığı mesajların konumunu ayarlıyor yani sağ tarafa hizalıyor bu kodlar olmayınca da sola hizalıyor
       // anchorConstraints.leading?.isActive = false
        //anchorConstraints.trailing?.isActive = true
        
        
        bubbleView.widthAnchor.constraint(lessThanOrEqualToConstant: 300).isActive = true
        bubbleView.layer.cornerRadius = 12
        
        bubbleView.addSubview(textView)
        textView.fillSuperview(padding: .init(top: 5, left: 12, bottom: 5, right: 12))
    }
}

