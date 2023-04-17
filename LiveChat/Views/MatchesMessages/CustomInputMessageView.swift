//
//  CustomInputMessageView.swift
//  LiveChat
//
//  Created by Hakan Körhasan on 16.04.2023.
//

import LBTATools
import UIKit

class CustomInputMessageView: UIView {
    
    let textView = UITextView()
    
    let sendButton = UIButton(title: "Send", titleColor: .black, font: .boldSystemFont(ofSize: 15), backgroundColor: .white, target: nil, action: nil)
    
    let placeholderText = UILabel(text: "Enter your message", font: .systemFont(ofSize: 15, weight: .regular), textColor: .lightGray)
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        setupShadow(opacity: 0.5, radius: 8, offset: .init(width: 0, height: -4), color: .lightGray)
        autoresizingMask = .flexibleHeight
        textView.isScrollEnabled = false
        textView.font = .systemFont(ofSize: 15)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextChange), name: UITextView.textDidChangeNotification, object: nil)
        
        hstack(textView,
               sendButton.withSize(.init(width: 60, height: 60)), alignment: .center).withMargins(.init(top: 14, left: 16, bottom: 0, right: 16))
        
        addSubview(placeholderText)
        
        placeholderText.anchor(top: nil, leading: leadingAnchor, bottom: nil, trailing: sendButton.trailingAnchor, padding: .init(top: 0, left: 20, bottom: 0, right: 0))
        placeholderText.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor).isActive = true
        
    }
    
    @objc fileprivate func handleTextChange() {
        placeholderText.isHidden = textView.text.count != 0
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
