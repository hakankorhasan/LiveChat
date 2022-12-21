//
//  CardView.swift
//  LiveChat
//
//  Created by Hakan Körhasan on 20.12.2022.
//

import UIKit

class CardView: UIView {

       let imageView = UIImageView(image: #imageLiteral(resourceName: "kelly3"))
       
       let informationLabel = UILabel()
    
       // Configurations
       fileprivate let threshold: CGFloat = 80

       override init(frame: CGRect) {
           super.init(frame: frame)
           // custom drawing code
           layer.cornerRadius = 10
           clipsToBounds = true
           
           imageView.contentMode = .scaleAspectFill
           addSubview(imageView)
           imageView.fillSuperview()
           
           // INFORMATION LABEL
           addSubview(informationLabel)
           informationLabel.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 16, bottom: 16, right: 16))
           informationLabel.text = "Test test test test"
           informationLabel.textColor = .white
           informationLabel.font = UIFont.systemFont(ofSize: 34, weight: .regular)
           informationLabel.numberOfLines = 0
           
           let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
           addGestureRecognizer(panGesture)
       }
       
       @objc fileprivate func handlePan(gesture: UIPanGestureRecognizer) {
           switch gesture.state {
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
           
           UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
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
