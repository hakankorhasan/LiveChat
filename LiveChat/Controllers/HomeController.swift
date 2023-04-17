//
//  ViewController.swift
//  LiveChat
//
//  Created by Hakan Körhasan on 20.12.2022.
//

import UIKit
import Firebase
import JGProgressHUD
import FirebaseFirestore

class HomeController: UIViewController, SettingsControllerDelegate, LoginControllerDelegate, CardViewDelegate {
    
    let topStackView = TopNavigationStackView()
    let cardsDeckView = UIView()
    let buttonControls = HomeBottomsControlsStackView()
        
    var cardViewModels = [CardViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        
        buttonControls.refreshButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        
        buttonControls.likeButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        
        buttonControls.dislikeButton.addTarget(self, action: #selector(handleDislike), for: .touchUpInside)
        
        topStackView.messageButton.addTarget(self, action: #selector(handleMessage), for: .touchUpInside)
        
        setupLayout()
        fetchCurrentUser()
        
    }
    
    @objc fileprivate func handleMessage() {
        let vc = MatchesMessagesController()
        vc.view.backgroundColor = .red
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Auth.auth().currentUser == nil {
            let registrationController = RegistrationController()
            registrationController.delegate = self
            let navController = UINavigationController(rootViewController: registrationController)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
        }
       
    }
    
    func didFinishLoggingIn() {
        fetchCurrentUser()
    }
        
    fileprivate let hud = JGProgressHUD(style: .dark)
    fileprivate var user: User?
    
    fileprivate func fetchCurrentUser() {
        hud.textLabel.text = "Loading"
        hud.show(in: view)
        cardsDeckView.subviews.forEach({$0.removeFromSuperview()})
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, err in
            if let err = err {
                print("fetch error", err)
                self.hud.dismiss()
                return
            }
            self.hud.dismiss()
            
            guard let dictionary = snapshot?.data() else { return }
            self.user = User(dictionary: dictionary)
            //self.fetchUsersFromFirestore()
            self.fetchSwipes()
        }
    }
    
    var swipes = [String: Int]()
    
    fileprivate func fetchSwipes() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("swipes").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("error", error)
                return
            }
            print("Swipes:", snapshot?.data() ?? "")
            guard let data = snapshot?.data() as? [String: Int] else { return }
            self.swipes = data
            self.fetchUsersFromFirestore()
        }
    }
    
    @objc fileprivate func handleRefresh() {
        cardsDeckView.subviews.forEach({$0.removeFromSuperview()})
        fetchUsersFromFirestore()
    }
    
    var lastFetchedUser: User?
    var topCardView: CardView?
   
    fileprivate func fetchUsersFromFirestore() {
        
       // guard let minAge = user?.minSeekingAge, let maxAge = user?.maxSeekingAge else { return }
        let minAge = SettingsController.defaultMinSeekingAge
        let maxAge = SettingsController.defaultMaxSeekingAge
        let db = Firestore.firestore()
        
        let docRef = db.collection("users").whereField("age", isGreaterThanOrEqualTo: minAge).whereField("age", isLessThanOrEqualTo: maxAge)
        //order(by: "uid").start(after: [lastFetchedUser?.uid ?? ""]).limit(to: 2)
        // paginate işlemi uid ye göre sıralar, verilen limit kadar kullanıcıyı gösterir
        topCardView = nil
        docRef.getDocuments { [self] (snapshot, error) in
            self.hud.dismiss()
            if let error = error {
                print("documents error", error)
                return
            }
            
            var previousCardView: CardView?
            
            
            snapshot?.documents.forEach({ (documentSnapshot) in
                
                let userDictionary = documentSnapshot.data()
                
                let user = User(dictionary: userDictionary)
                
                self.users[user.uid ?? ""] = user
                
                let isNotCurrentUser = user.uid != Auth.auth().currentUser?.uid
                //let hasNotSwipedBefore = self.swipes[user.uid!] == nil
                let hasNotSwipedBefore = true
                if isNotCurrentUser && hasNotSwipedBefore {
                    let cardView = self.setupCardFromUser(user: user)
                    
                    previousCardView?.nextCardView = cardView
                    previousCardView = cardView
                    
                    if self.topCardView == nil {
                        self.topCardView = cardView
                    }
                }
                
            })
        }
    }
    
    var users = [String: User]()
    
    @objc func handleDislike() {
        saveSwipeToFirebase(didLike: 0)
        swipeAnimation(translition: -700, angle: -15)
    }
    
    @objc func handleLike() {
        saveSwipeToFirebase(didLike: 1)
        swipeAnimation(translition: 700, angle: 15)
    }
    
    fileprivate func saveSwipeToFirebase(didLike: Int) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        guard let cardUUID = topCardView?.cardViewModel.uid else { return }
        
        let documentData = [cardUUID: didLike]
        
        let db = Firestore.firestore().collection("swipes").document(uid)
        
        db.getDocument { (snapshot, error) in
            if let error = error {
                print("Failed to fetch", error)
                return
            }
            // eğer daha önce swipes collection ı oluşturulmamışsa
            // yani kullanıcı yeni kayıt olmuş sa snapshot false döner ve setData ile swipes oluşturulur sonrasında kayıt eder
            // snapshot true ise yani daha önceden swipes koleksiyonu oluşturulmuş ise update methodu tetiklenir
            if snapshot?.exists == true {
                db.updateData(documentData) { (error) in
                    if let error = error {
                        print("update is not working", error)
                        return
                    }
                    print("Successfully update data")
                    
                    if didLike == 1 {
                        self.checkIfMatch(cardUUID: cardUUID)
                    }
                }
            } else {
                db.setData(documentData) { (error) in
                    if let error = error {
                        print("Failed data saving", error)
                        return
                    }
                    print("Successfully saving swipes")
                    
                    if didLike == 1 {
                        self.checkIfMatch(cardUUID: cardUUID)
                        
                    }
                }
            }
        }
    }
    
    fileprivate func checkIfMatch(cardUUID: String) {
        print("Detecting match")
        
        Firestore.firestore().collection("swipes").document(cardUUID).getDocument { (snapshot, err) in
            if let err = err {
                print("Failed to fetch document for card user:", err)
                return
            }
            
            guard let data = snapshot?.data() else { return }
            print(data)
            
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            let hasMatched = data[uid] as? Int == 1
            if hasMatched {
                print("Has matched")
                self.presentMatchView(cardUUID: cardUUID)
                
                guard let cardUser = self.users[cardUUID] else { return }
                
                let data = ["name": cardUser.name ?? "", "profileImageUrl": cardUser.imageUrl1 ?? "", "uid": uid, "timestamp": Timestamp(date: Date())]
                
                Firestore.firestore().collection("matches_messages").document(uid).collection("matches").document(cardUUID).setData(data, completion: { (error) in
                    if error != nil {
                        return
                    }
                })
                
                guard let currentUser = self.user else { return }
                
                let currentUserData = ["name": currentUser.name ?? "", "profileImageUrl": currentUser.imageUrl1 ?? "", "uid": cardUUID, "timestamp": Timestamp(date: Date())]
                
                Firestore.firestore().collection("matches_messages").document(cardUUID).collection("matches").document(uid).setData(data, completion: { (error) in
                    if error != nil {
                        return
                    }
                })
                
            }
        }
    }
    
    fileprivate func presentMatchView(cardUUID: String) {
        let matchView = MatchView()
        matchView.cardUUID = cardUUID
        matchView.currentUser = self.user
        view.addSubview(matchView)
        matchView.fillSuperview()
        
    }
    
    fileprivate func swipeAnimation(translition: CGFloat, angle: CGFloat) {
        let translitionAnimation = CABasicAnimation(keyPath: "position.x")
        translitionAnimation.toValue = translition
        translitionAnimation.duration = 0.5
        translitionAnimation.fillMode = .forwards
        translitionAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        translitionAnimation.isRemovedOnCompletion = false
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = angle * CGFloat.pi / 180
        rotationAnimation.duration = 0.5
        
        let cardView = topCardView
        topCardView = cardView?.nextCardView
        
        CATransaction.setCompletionBlock {
            cardView?.removeFromSuperview()
        }
        
        cardView?.layer.add(translitionAnimation, forKey: "translition")
        cardView?.layer.add(rotationAnimation, forKey: "rotation")
        
        CATransaction.commit()
    }
    
   
    
    func didRemoveCars(cardView: CardView) {
        self.topCardView?.removeFromSuperview()
        self.topCardView = self.topCardView?.nextCardView
    }
    
    fileprivate func setupCardFromUser(user: User) -> CardView {
        let cardView = CardView(frame: .zero)
        cardView.delegate = self
        cardView.cardViewModel = user.toCardViewModel()
        cardsDeckView.addSubview(cardView)//görüntü üzerine görüntü ekledik
        cardsDeckView.sendSubviewToBack(cardView) // her seferinde farklı kullanıcıların gelmesini sağladı
        cardView.fillSuperview()
        return cardView
    }
    
    func didTapMoreInfo(cardViewModel: CardViewModel) {
        print("fetch user details", cardViewModel.attributedString)
        let userDetailsController = UserDetailsController()
        userDetailsController.modalPresentationStyle = .fullScreen
        userDetailsController.cardViewModel = cardViewModel
        self.present(userDetailsController, animated: true)
    }
    
    
    @objc func handleSettings() {
        let settingsController = SettingsController()
        settingsController.delegate = self
        let navController = UINavigationController(rootViewController: settingsController)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true) // sayfalar arası geçiş
        
    }
    
    func didSaveSettings() {
        fetchCurrentUser()
    }

    fileprivate func setupFirestoreUserCards() {
        cardViewModels.forEach { (cardVM) in
            let cardView = CardView(frame: .zero)
            cardView.cardViewModel = cardVM
            cardsDeckView.addSubview(cardView)//görüntü üzerine görüntü ekledik
            cardView.fillSuperview()
        }
    }
    
    // MARK: -Fileprivate
    
    fileprivate func setupLayout() {
        view.backgroundColor = .white
        let overallStackView = UIStackView(arrangedSubviews: [topStackView, cardsDeckView, buttonControls])
        overallStackView.axis = .vertical
        view.addSubview(overallStackView)
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        overallStackView.isLayoutMarginsRelativeArrangement = true
        overallStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        overallStackView.bringSubviewToFront(cardsDeckView)
        
    }

}

