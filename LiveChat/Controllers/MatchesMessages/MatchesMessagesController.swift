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

struct Match {
    let name, profileImageUrl: String
    
    init(dictionary: [String: Any]) {
        self.name = dictionary["name"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
    }
}

class MatchCell: LBTAListCell<Match> {
    
    let profileImageView = UIImageView(image: #imageLiteral(resourceName: "kelly3"), contentMode: .scaleAspectFill)
    
    let usernameLabel = UILabel(text: "Herny Cavel", font: .systemFont(ofSize: 14, weight: .semibold), textColor: .black, textAlignment: .center, numberOfLines: 2)
    
    override var item: Match! {
        didSet {
            usernameLabel.text = item.name
            profileImageView.sd_setImage(with: URL(string: item.profileImageUrl))
            
        }
    }
    
    override func setupViews() {
        super.setupViews()
        
        profileImageView.clipsToBounds = true
        profileImageView.constrainWidth(80)
        profileImageView.constrainHeight(80)
        profileImageView.layer.cornerRadius = 80 / 2
        
        stack(stack(profileImageView, alignment: .center), usernameLabel)
    }
}

class MatchesMessagesController: LBTAListController<MatchCell, Match>, UICollectionViewDelegateFlowLayout {
    
    let customNavBar = MatchesNavBar()
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 120, height: 140)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let matchIndexPath = items[indexPath.item]
        let chatLogController = ChatLogController(match: matchIndexPath)
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /*items = [
            .init(name: "Full namer", profileImageUrl: "https://firebasestorage.googleapis.com:443/v0/b/livec-81519.appspot.com/o/images%2F48C1CA52-E367-4A2F-AB54-F7CDF9615888?alt=media&token=15e24de0-3c3c-4ab9-901c-75d5dd4e6eb1"),
            .init(name: "Full namer", profileImageUrl: "https://firebasestorage.googleapis.com:443/v0/b/livec-81519.appspot.com/o/images%2FD7A446D2-864D-40D1-BB9B-79E8B117CFBF?alt=media&token=82ab8440-dcc5-45dd-bada-917349d42748"),
            .init(name: "Full namer", profileImageUrl: "profile imge url")
        ]*/
        
        fetcheMatches()
        
        collectionView.backgroundColor = .white
        
        customNavBar.backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        
        view.addSubview(customNavBar)
        customNavBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, size: .init(width: 0, height: 150))
        
        collectionView.contentInset.top = 150
    }
    
    fileprivate func fetcheMatches() {
        guard let currentUser = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("matches_messages").document(currentUser).collection("matches").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("fetch error", error)
                return
            }
            
            var matches = [Match]()
            
            querySnapshot?.documents.forEach({ (documentSnapshot) in
                print(documentSnapshot.data())
                let dictionary = documentSnapshot.data()
                matches.append(.init(dictionary: dictionary))
            })
            
            self.items = matches
            self.collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 16, bottom: 0, right: 0)
    }

    @objc fileprivate func handleBack() {
        navigationController?.popViewController(animated: true)
    }
  
}
