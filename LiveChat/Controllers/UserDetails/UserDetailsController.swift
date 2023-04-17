//
//  UserDetailsController.swift
//  LiveChat
//
//  Created by Hakan Körhasan on 8.04.2023.
//

import UIKit
import SDWebImage

class UserDetailsController: UIViewController, UIScrollViewDelegate {
    
    var cardViewModel: CardViewModel! {
        didSet {
            infoLabel.attributedText = cardViewModel.attributedString
            swipingPhotosController.cardViewModel = cardViewModel
        }
    }
    
    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = .white
        sv.alwaysBounceVertical = true//vertical şeklinde scrollanabilmeyi sağladı
        sv.contentInsetAdjustmentBehavior = .never
        sv.delegate = self
        return sv
    }()
    
    let swipingPhotosController = SwipingPhotosController()
    
    let downArrow: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "dismiss_down_arrow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Ben Hakan\nYaşım 22\nYazılımcıyım"
        label.numberOfLines = 0
        return label
    }()
    
    fileprivate func createButton(image: UIImage, selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.contentMode = .scaleAspectFill
        return button
    }
    
    lazy var dislikeButton = self.createButton(image: #imageLiteral(resourceName: "dismiss_circle"), selector: #selector(handleDislike))
    
    lazy var superlikeButton = self.createButton(image: #imageLiteral(resourceName: "super_like_circle"), selector: #selector(handleSuperlike))
    
    lazy var likeButton = self.createButton(image: #imageLiteral(resourceName: "like_circle"), selector: #selector(handleLike))
    
    @objc fileprivate func handleDislike() {
        
    }
    
    @objc fileprivate func handleSuperlike() {
        
    }
    
    @objc fileprivate func handleLike() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        setupLayout()
       
        setupVisualBlurEffect()
        
        setupBottomControls()
        
    }
    
    
    fileprivate func setupBottomControls() {
        let stackView = UIStackView(arrangedSubviews: [
            dislikeButton,
            superlikeButton,
            likeButton
        ])
        stackView.distribution = .fillEqually
        stackView.spacing = -32
        view.addSubview(stackView)
        stackView.anchor(top: nil, leading: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 300, height: 80))
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    fileprivate func setupVisualBlurEffect() {
        let blureffect = UIBlurEffect(style: .regular)
        let visualEffect = UIVisualEffectView(effect: blureffect)
        view.addSubview(visualEffect)
        visualEffect.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
    }
    
    fileprivate func setupLayout() {
        view.addSubview(scrollView)
        scrollView.fillSuperview()
        
        let imageView = swipingPhotosController.view!

        scrollView.addSubview(imageView)
        
        scrollView.addSubview(infoLabel)
        infoLabel.anchor(top: imageView.bottomAnchor, leading: scrollView.leadingAnchor, bottom: nil, trailing: scrollView.trailingAnchor, padding: .init(top: 16, left: 16, bottom: 16, right: 16))
        
        scrollView.addSubview(downArrow)
        downArrow.anchor(top: imageView.bottomAnchor, leading: nil, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: -25, left: 0, bottom: 0, right: 25), size: .init(width: 50, height: 50))
    }
    
    //detaya gidilmeden önce imageView ın boyutları ayarlanır, eğer bu şekilde kullanmazsak default tam ekran olarak açılır
    
    fileprivate let extraSwipingHeight: CGFloat = 80
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let swipingView = swipingPhotosController.view!
        swipingView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width + extraSwipingHeight)

    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = -scrollView.contentOffset.y
        var width = view.frame.width + y * 2
        width = max(view.frame.width, width)
        let imageView = swipingPhotosController.view!
        imageView.frame = CGRect(x: min(0, -y), y: min(0, -y), width: width, height: width + extraSwipingHeight)
    
    }

    @objc fileprivate func handleDismiss() {
        self.dismiss(animated: true)
    }
}
