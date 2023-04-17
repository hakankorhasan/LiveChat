//
//  ChatLogController.swift
//  LiveChat
//
//  Created by Hakan Körhasan on 16.04.2023.
//

import LBTATools
import UIKit

struct Message {
    let text: String
    let isFromCurrentLoggedUser: Bool
}

class MessageCell: LBTAListCell<Message> {
    
    let textView: UITextView = {
       let tv = UITextView()
        tv.backgroundColor = .clear
        tv.font = .systemFont(ofSize: 20)
        tv.isScrollEnabled = false
        tv.isEditable = false
        return tv
    }()
    
    let bubbleView = UIView(backgroundColor: UIColor(#colorLiteral(red: 0.8054330945, green: 0.8107859492, blue: 0.8106914759, alpha: 0.8470588235)))
    
    override var item: Message! {
        didSet {
            textView.text = item.text
            
            if item.isFromCurrentLoggedUser {
                anchoredConstraints.leading?.isActive = false
                anchoredConstraints.trailing?.isActive = true
                textView.tintColor = .white
                bubbleView.backgroundColor = UIColor(#colorLiteral(red: 0.2034923434, green: 0.7475703359, blue: 1, alpha: 0.6253658421))
            } else {
                anchoredConstraints.leading?.isActive = true
                anchoredConstraints.trailing?.isActive = false
                textView.tintColor = .white
                bubbleView.backgroundColor = UIColor(#colorLiteral(red: 0.8054330945, green: 0.8107859492, blue: 0.8106914759, alpha: 0.8470588235))
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

class ChatLogController: LBTAListController<MessageCell, Message>, UICollectionViewDelegateFlowLayout {
    
    lazy var customInputMessageView: UIView = {
        return CustomInputMessageView(frame: .init(x: 0, y: 0, width: view.frame.width, height: 50))
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return customInputMessageView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    fileprivate let match: Match
    
    fileprivate lazy var messageNavBar = MessagesNavBar(match: match)
    
    fileprivate let navBarHeight: CGFloat = 120
    
    init(match: Match) {
        self.match = match
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.alwaysBounceVertical = true
        
        items = [
            .init(text: "For this lesson, let's talk all about auto sizing message cells and how to shift alignment from left to right.  Doing the alignment correctly within one cell makes it very easy to toggle things based on a chat message's properties later on.  We'll also look at some bug fixes at the end.", isFromCurrentLoggedUser: true),
            .init(text: "hel", isFromCurrentLoggedUser: false),
            .init(text: " We'll also look at some ", isFromCurrentLoggedUser: false),
            .init(text: "For this lesson, let's talk all about auto sizing message cells and how to shift alignment from left to right.  Doing the alignment correctly within one cell makes it very easy to toggle things based on a chat message's properties later on.  We'll also look at some bug fixes at the end. For this lesson, let's talk all about auto sizing message cells and how to shift alignment from left to right.", isFromCurrentLoggedUser: true),
            .init(text: "For this lesson, let's talk all about auto sizing message cells and how to shift alignment from left to right.  Doing the alignment correctly within one cell makes it very easy to toggle things based on a chat message's properties later on.  We'll also look at some bug fixes at the end.", isFromCurrentLoggedUser: false)
        ]
        
        view.addSubview(messageNavBar)
        messageNavBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, size: .init(width: 0, height: navBarHeight))
        
        collectionView.contentInset.top = navBarHeight
        collectionView.verticalScrollIndicatorInsets.top = navBarHeight
        
        messageNavBar.backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        
        let statusBarCover = UIView(backgroundColor: .white)
        view.addSubview(statusBarCover)
        statusBarCover.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
    }
    
    @objc fileprivate func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 0, bottom: 16, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let estimetedSizeCell = MessageCell(frame: .init(x: 0, y: 0, width: view.frame.width, height: 1000))
        estimetedSizeCell.item = self.items[indexPath.item]
        
        estimetedSizeCell.layoutIfNeeded() // bu kod item daki textlerin boyutunu anlık olarak belirliyor ve aşağıda işlemler buna göre devam ediyor
        //Bu metod, bir UIView nesnesinde alt öğelerin yerleşimi değiştirildiğinde kullanışlıdır. Örneğin, bir alt öğe boyutunu veya konumunu değiştirdiğimizde, alt öğenin güncellenmesi için layoutIfNeeded() metodunu çağırmalıyız.
        
        let estimetedSize = estimetedSizeCell.systemLayoutSizeFitting(.init(width: view.frame.width, height: 1000))
        
        return .init(width: view.frame.width, height: estimetedSize.height)
    }
}


