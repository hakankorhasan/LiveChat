//
//  CardView.swift
//  LiveChat
//
//  Created by Hakan Körhasan on 20.12.2022.
//

import UIKit

class CardView: UIView {

    
    var cardViewModel: CardViewModel! {
        didSet {
            let imageName = cardViewModel.imageNames.first ?? ""
            imageView.image = UIImage(named: imageName)
            informationLabel.attributedText = cardViewModel.attributedString
            informationLabel.textAlignment = cardViewModel.textAlignment
            
            (0..<cardViewModel.imageNames.count).forEach { (_) in
                let barView = UIView()
                barView.backgroundColor = barDeselectedColor
                barsStackView.addArrangedSubview(barView)
            }
            barsStackView.arrangedSubviews.first?.backgroundColor = .white
            
            setupImageIndexObserver()
        }
    }
    
    fileprivate func setupImageIndexObserver() {
        cardViewModel.imageIndexObserver = { [weak self] (index, image) in
            self?.imageView.image = image
            
            self?.barsStackView.arrangedSubviews.forEach { (v) in
                v.backgroundColor = self?.barDeselectedColor
            }
            self?.barsStackView.arrangedSubviews[index].backgroundColor = .white
        }
    }
    
    // encapsulation
    fileprivate let imageView = UIImageView(image: #imageLiteral(resourceName: "kelly3"))
    fileprivate let informationLabel = UILabel()
    fileprivate let gradientLayer = CAGradientLayer()
    fileprivate let barDeselectedColor = UIColor(white: 0, alpha: 0.1)
    fileprivate let barsStackView = UIStackView()
    
    // Configurations
    fileprivate let threshold: CGFloat = 80
    
    override init(frame: CGRect) {
           super.init(frame: frame)
        setupLayout()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(panGesture)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    var imageIndex = 0
    
    @objc fileprivate func handleTap(gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: nil)
        print("handling tap")
        let shouldAdvanceNextPhoto = tapLocation.x > frame.width / 2 ? true : false
        if shouldAdvanceNextPhoto {
            cardViewModel.advanceNextPhoto()
        }else {
            cardViewModel.goToPreviousPhoto()
        }
    }
    
    fileprivate func setupLayout() {
        // custom drawing code
        layer.cornerRadius = 10
        clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        addSubview(imageView)
        imageView.fillSuperview()
        
        setupBarsStackView()
        
        //SETUP GRADIENT LAYER
        setupGradientLayer()
        
        // INFORMATION LABEL
        addSubview(informationLabel)
        informationLabel.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 16, bottom: 16, right: 16))
        informationLabel.textColor = .white
        informationLabel.numberOfLines = 0
        
    }
    
    fileprivate func setupBarsStackView() {
        addSubview(barsStackView)
        barsStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 8, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 4))
        barsStackView.spacing = 4
        barsStackView.distribution = .fillEqually
    }
    
    fileprivate func setupGradientLayer(){
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.5, 1.1]
        layer.addSublayer(gradientLayer)
    }
    
    override func layoutSubviews() {
        gradientLayer.frame = self.frame
    }
       
    @objc fileprivate func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            //fotoğraf kaydırdıktan sonra siler, bu kod olmazsa bug yaşanır, fotolar ekrana geri yansır
            superview?.subviews.forEach({ (subview) in
                subview.layer.removeAllAnimations()
            })
        case .changed:
            handleChanged(gesture)
        case .ended:
            handleEnded(gesture: gesture)
        default:
            ()
        }
    }
       
    fileprivate func handleChanged(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: nil)
        // rotation
        // some not that scary math here to convert radians to degrees
        let degrees: CGFloat = translation.x / 20
        let angle = degrees * .pi / 180
        
        let rotationalTransformation = CGAffineTransform(rotationAngle: angle)
        self.transform = rotationalTransformation.translatedBy(x: translation.x, y: translation.y)
    }
       
    fileprivate func handleEnded(gesture: UIPanGestureRecognizer) {
        let translationDirection: CGFloat = gesture.translation(in: nil).x > 0 ? 1 : -1
        let shouldDismissCard = abs(gesture.translation(in: nil).x) > threshold
           
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options:.curveEaseOut, animations: {
            if shouldDismissCard {
                self.frame = CGRect(x: 1000 * translationDirection, y: 0, width: self.frame.width, height: self.frame.height)
            } else {
                self.transform = .identity
            }
               
        }) { (_) in
            self.transform = .identity
            if shouldDismissCard {
                self.removeFromSuperview()
            }
            //  self.frame = CGRect(x: 0, y: 0, width: self.superview!.frame.width, height: self.superview!.frame.height)
        }
    }
       
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
