//
//  MatchView.swift
//  LiveChat
//
//  Created by Hakan Körhasan on 12.04.2023.
//

import UIKit
import Firebase
import SDWebImage

class MatchView: UIView {
    
    var currentUser: User! {
        didSet {
            
        }
    }
    
    var cardUUID: String! {
        didSet {
            
            Firestore.firestore().collection("users").document(cardUUID).getDocument { (snapshot, error) in
                
                if let error = error {
                    print("fetch carduuid error", error)
                    return
                }
                
                guard let dictionary = snapshot?.data() else { return }
                let user = User(dictionary: dictionary)
                guard let url = URL(string: user.imageUrl1 ?? "") else { return }
                self.cardUserImageView.sd_setImage(with: url)
                
                guard let currentUserImageUrl = URL(string: self.currentUser.imageUrl1 ?? "") else { return }
                self.currentUserImageView.sd_setImage(with: currentUserImageUrl)
                
                self.setupAnimation()
            }
        }
    }
    
    fileprivate let itsAMatchImageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "itsamatch"))
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    fileprivate let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "You and X have liked\neach other"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    fileprivate let currentUserImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "kelly1"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        return imageView
    }()
    
    fileprivate let cardUserImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "jane2"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        return imageView
    }()
    
    fileprivate let sendMessageButton: UIButton = {
        let button = SendMessageButton()
        button.setTitle("SEND MESSAGE", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    fileprivate let keepSwipingButton: UIButton = {
        let button = KeepSwipingButton()
        button.setTitle("Keep Swiping", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    lazy var views = [
        itsAMatchImageView,
        descriptionLabel,
        currentUserImageView,
        cardUserImageView,
        sendMessageButton,
        self.keepSwipingButton
    ]
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBlurView()
        setupLayout()
    }
    
    fileprivate func setupLayout() {
        views.forEach { (v) in
            addSubview(v)
            v.alpha = 0
        }
        
        let imageSize: CGFloat = 140
        
        itsAMatchImageView.anchor(top: nil, leading: nil, bottom: descriptionLabel.topAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: 16, right: 0), size: .init(width: 150, height: 80))
        itsAMatchImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        descriptionLabel.anchor(top: nil, leading: self.leadingAnchor, bottom: currentUserImageView.topAnchor, trailing: self.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 32, right: 0), size: .init(width: 0, height: 50))
        
        currentUserImageView.anchor(top: nil, leading: nil, bottom: nil, trailing: centerXAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 16), size: .init(width: imageSize, height: imageSize))
        currentUserImageView.layer.cornerRadius = imageSize / 2
        currentUserImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        
        cardUserImageView.anchor(top: nil, leading: centerXAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: 16, bottom: 0, right: 0), size: .init(width: imageSize, height: imageSize))
        cardUserImageView.layer.cornerRadius = imageSize / 2
        cardUserImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        sendMessageButton.anchor(top: currentUserImageView.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 32, left: 48, bottom: 0, right: 48), size: .init(width: 0, height: 60))
        
        keepSwipingButton.anchor(top: sendMessageButton.bottomAnchor, leading: sendMessageButton.leadingAnchor, bottom: nil, trailing: sendMessageButton.trailingAnchor, padding: .init(top: 16, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 60))
    }
    
    
    fileprivate func setupAnimation() {
        views.forEach({$0.alpha = 1})
        
       // let angle = 30 * CGFloat.pi / 180
        let angle = 30 * CGFloat.pi / 180
        currentUserImageView.transform = CGAffineTransform(rotationAngle: -angle).concatenating(CGAffineTransform(translationX: 200, y: 0)) //yer değiştirdiler x ekseninde +200 konumuna yerleştirdik
        cardUserImageView.transform = CGAffineTransform(rotationAngle: angle).concatenating(CGAffineTransform(translationX: -200, y: 0))
        
        sendMessageButton.transform = CGAffineTransform(translationX: -500, y: 0)
        keepSwipingButton.transform = CGAffineTransform(translationX: 500, y: 0)
        //concatenating ile farklı transform özelliklerini birleştiripi kullanabiliriz
        //current user yerine carduser geçti
        
        //animasyonlar identity yani varsayılan konumlarına geri getireceğiz
        //iç içe geçmiş olan animasyonlarda animateKeyFrames kolaylık sağlayabilir
        UIView.animateKeyframes(withDuration: 1.3, delay: 0) {
            //bu animasyonun toplam süresi 1.2 sn
            //ilk çalışmasını istediğimiz animasyon 0 yani hemen çalışmaya başlayacak
            //0.5 ms sürecek
            //ve bitecek
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.45) {
                self.currentUserImageView.transform = CGAffineTransform(rotationAngle: -angle)
                self.cardUserImageView.transform = CGAffineTransform(rotationAngle: angle)
                
            }
            //ilk animasyon 0.5 ms süreceği için bunu da 0.5 ms de başlatabiliriz
            //bu animasyonda 0.5 ms sürüp bitecek
            UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4) {
                self.currentUserImageView.transform = .identity
                self.cardUserImageView.transform = .identity
              //  self.sendMessageButton.transform = .identity
                //self.keepSwipingButton.transform = .identity
                //burada kullanınca çok yavaş geliyorlar biz daha hızlı gelmesini istiyoruz
            }
            
           /* UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.2) {
                    self.currentUserImageView.transform = CGAffineTransform(translationX: -200, y: 0)
                    self.cardUserImageView.transform = CGAffineTransform(translationX: 200, y: 0)
                }*/
        }
        
        UIView.animate(withDuration: 0.75, delay: 0.6 * 1.3, usingSpringWithDamping: 0.45, initialSpringVelocity: 0.1, options: .curveEaseOut) {
            self.sendMessageButton.transform = .identity
            self.keepSwipingButton.transform = .identity
        }
        
    }
    
    let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    fileprivate func setupBlurView() {
        visualEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss)))
        addSubview(visualEffectView)
        visualEffectView.fillSuperview()
        visualEffectView.alpha = 0
            
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.visualEffectView.alpha = 1
        }) { (_) in
            
       }

    }
    
    @objc fileprivate func handleTapDismiss() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.alpha = 0
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
