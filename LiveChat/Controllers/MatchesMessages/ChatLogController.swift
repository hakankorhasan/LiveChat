//
//  ChatLogController.swift
//  LiveChat
//
//  Created by Hakan Körhasan on 16.04.2023.
//

import LBTATools
import UIKit
import Firebase

class ChatLogController: LBTAListController<MessageCell, Message>, UICollectionViewDelegateFlowLayout {
    
    init(match: Match) {
        self.match = match
        super.init()
    }
    
    lazy var customInputMessageView: CustomInputMessageView = {
        let civ = CustomInputMessageView(frame: .init(x: 0, y: 0, width: view.frame.width, height: 50))
        civ.sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return civ
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

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var currentUser: User?
    
    fileprivate func fetchCurrentUser() {
        Firestore.firestore().collection("users").document(Auth.auth().currentUser?.uid ?? "").getDocument { (snapshot, err) in
            if let err = err {
                return
            }
            
            let data = snapshot?.data() ?? [:]
            self.currentUser = User(dictionary: data)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchCurrentUser()
        
        collectionView.alwaysBounceVertical = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        fetchMessages()
        
        view.addSubview(messageNavBar)
        messageNavBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, size: .init(width: 0, height: navBarHeight))
        
        collectionView.contentInset.top = navBarHeight
        collectionView.verticalScrollIndicatorInsets.top = navBarHeight
        
        messageNavBar.backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        
        let statusBarCover = UIView(backgroundColor: .white)
        view.addSubview(statusBarCover)
        statusBarCover.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
    }
    
    @objc fileprivate func handleKeyboardShow() {
        self.collectionView.scrollToItem(at: [0, items.count - 1], at: .bottom, animated: true)
    }
    
    @objc fileprivate func handleSend() {
        
        saveToFromMessages()
        saveToFromRecentMessages()
        
    }
    
    fileprivate func saveToFromRecentMessages() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let data = ["text": customInputMessageView.textView.text ?? "", "name": match.name, "profileImageUrl": match.profileImageUrl, "uid": match.uid, "timestamp": Timestamp(date: Date())] as [String: Any]
        
        Firestore.firestore().collection("matches_messages").document(currentUserId).collection("recent_messages").document(match.uid).setData(data) { (error) in
            
            if let error = error {
                return
            }
        }
        
        guard let currentUser = self.currentUser else { return }
        
        let toData = ["text": customInputMessageView.textView.text ?? "", "name": currentUser.name ?? "", "profileImageUrl": currentUser.imageUrl1 ?? "", "uid": currentUserId, "timestamp": Timestamp(date: Date())] as [String: Any]
        
        Firestore.firestore().collection("matches_messages").document(match.uid).collection("recent_messages").document(currentUserId).setData(toData)
    }
    
    fileprivate func saveToFromMessages() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let collection = Firestore.firestore().collection("matches_messages").document(currentUserId).collection(match.uid)
        
        let data = ["text": customInputMessageView.textView.text ?? "", "fromId": currentUserId, "toId": match.uid, "timestamp": Timestamp(date: Date())] as [String : Any]
        
        collection.addDocument(data: data) { (err) in
            if let err = err {
                print("Failed to save message:", err)
                return
            }
            
            print("Successfully saved msg into Firestore")
            self.customInputMessageView.textView.text = nil
            self.customInputMessageView.placeholderText.isHidden = false
        }
        
        let toCollection = Firestore.firestore().collection("matches_messages").document(match.uid).collection(currentUserId)
        
        toCollection.addDocument(data: data) { (err) in
            if let err = err {
                print("Failed to save message:", err)
                return
            }
            
            print("Successfully saved msg into Firestore")
            self.customInputMessageView.textView.text = nil
            self.customInputMessageView.placeholderText.isHidden = false
        }
    }
    
    @objc fileprivate func fetchMessages() {
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let query = Firestore.firestore().collection("matches_messages").document(currentUserId).collection(match.uid).order(by: "timestamp")
        
        query.addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("failed to fetch messages, ", error)
                return
            }
            
            querySnapshot?.documentChanges.forEach({ (change) in
                if change.type == .added {
                    let dict = change.document.data()
                    self.items.append(.init(dictionary: dict))
                }
            })
            self.collectionView.reloadData()
            self.collectionView.scrollToItem(at: [0, self.items.count - 1], at: .bottom, animated: true)
        }
        
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


