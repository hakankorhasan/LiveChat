//
//  MatchesMessagesController.swift
//  LiveChat
//
//  Created by Hakan Körhasan on 15.04.2023.
//

import UIKit
import LBTATools
import SDWebImage
import Firebase

struct RecentMessage {
    let text, name, profileImageUrl, uid: String
    let timestamp: Timestamp
    
    init(dictionary: [String: Any]) {
        self.text = dictionary["text"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
    }
}

class RecentMessageCell: LBTAListCell<RecentMessage> {
    
    let profileImageView = UIImageView(image: #imageLiteral(resourceName: "kelly3"), contentMode: .scaleAspectFill)
    
    let usernameLabel = UILabel(text: "Kelly Ann", font: .boldSystemFont(ofSize: 18), textColor: .black)
    
    let messageLabel = UILabel(text: "Im hakan. Nice to meet you. how are you?", font: .systemFont(ofSize: 15), textColor: .gray, numberOfLines: 0)
    
    override var item: RecentMessage! {
        didSet {
            usernameLabel.text = item.name
            messageLabel.text = item.text
            profileImageView.sd_setImage(with: URL(string: item.profileImageUrl))
        }
    }
    
    override func setupViews() {
        super.setupViews()
        
        profileImageView.layer.cornerRadius = 94/2
        
        hstack(profileImageView.withWidth(94).withHeight(94),
               stack(usernameLabel, messageLabel, spacing: 4), spacing: 20, alignment: .center).padLeft(20).padRight(20)
        
        addSeparatorView(leadingAnchor: usernameLabel.leadingAnchor)
    }
}

class MatchesHeader: UICollectionReusableView {
    
    let newMatchesLabel = UILabel(text: "New Matches", font: .boldSystemFont(ofSize: 15), textColor: #colorLiteral(red: 0.978428781, green: 0.3918142915, blue: 0.5514227152, alpha: 1))
    
    let horizontalView = MatchesHorizontalController()
    
    let messageslabel = UILabel(text: "Messages", font: .boldSystemFont(ofSize: 15), textColor: #colorLiteral(red: 0.978428781, green: 0.3918142915, blue: 0.5514227152, alpha: 1))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        stack(stack(newMatchesLabel).padLeft(20) ,
              horizontalView.view,
              stack(messageslabel).padLeft(20), spacing: 20
        ).withMargins(.init(top: 20, left: 0, bottom: 10, right: 0))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



class MatchesMessagesController: LBTAListHeaderController<RecentMessageCell, RecentMessage, MatchesHeader>, UICollectionViewDelegateFlowLayout {
    
    var recentMessagesDictionary = [String: RecentMessage]()
    
    @objc fileprivate func fetchRecentMessage() {
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("matches_messages").document(currentUserId).collection("recent_messages").addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                return
            }
            
            querySnapshot?.documentChanges.forEach({ (change) in
                if change.type == .added || change.type == .modified {
                    let dictionary = change.document.data()
                    let recentMessage = RecentMessage(dictionary: dictionary)
                    self.recentMessagesDictionary[recentMessage.uid] = recentMessage
                }
            })
            
            self.resetItems()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let recentMessage = self.items[indexPath.item]
        let dictionary = ["name": recentMessage.name, "profileImageUrl": recentMessage.profileImageUrl, "uid": recentMessage.uid]
        let match = Match(dictionary: dictionary)
        let controller = ChatLogController(match: match)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    fileprivate func resetItems() {
        let values = Array(recentMessagesDictionary.values)
        items = values.sorted(by: { (rm1, rm2) -> Bool in
            return rm1.timestamp.compare(rm2.timestamp) == .orderedDescending
        })
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func setupHeader(_ header: MatchesHeader) {
        header.horizontalView.rootMatchesController = self
    }
    
    func didSelectFromHeader(match: Match) {
        let chatLogController = ChatLogController(match: match)
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: view.frame.width, height: 250)
    }
    
    let customNavBar = MatchesNavBar()
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: 130)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchRecentMessage()
      
        setupUI()
        
    }
    
    fileprivate func setupUI() {
        collectionView.backgroundColor = .white
        
        customNavBar.backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        
        view.addSubview(customNavBar)
        customNavBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, size: .init(width: 0, height: 150))
        
        collectionView.contentInset.top = 150
        collectionView.verticalScrollIndicatorInsets.top = 150
        
        let statusBarCover = UIView(backgroundColor: .white)
        view.addSubview(statusBarCover)
        statusBarCover.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: 16, bottom: 0, right: 0)
    }

    @objc fileprivate func handleBack() {
        navigationController?.popViewController(animated: true)
    }
  
}
