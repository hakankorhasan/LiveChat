//
//  ViewController.swift
//  LiveChat
//
//  Created by Hakan Körhasan on 20.12.2022.
//

import UIKit

class HomeController: UIViewController {

    let topStackView = TopNavigationStackView()
    let cardsDeckView = UIView()
    let buttonsStackView = HomeBottomsControlsStackView()
    
    let cardViewModels: [CardViewModel] = {
        let producers = [
            User(name: "Kelly", age: 23, profession: "Teacher", imageNames: ["kelly1", "kelly2", "kelly3"]),
            User(name: "Jane", age: 18, profession: "Developer", imageNames: ["jane1", "jane2", "jane3"]),
            Advertiser(title: "Slide Out", brandName: "öylesine bişeyler", posterPhotoName: "slide_out_menu_poster")
        ] as [ProducesCardViewModel]
        
        let viewModels = producers.map( { return $0.toCardViewModel() } )
        return viewModels
    }()
        
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupDummyCards()
    }

    fileprivate func setupDummyCards() {
        cardViewModels.forEach { (cardVM) in
            let cardView = CardView(frame: .zero)
            cardView.cardViewModel = cardVM
            cardsDeckView.addSubview(cardView)//görüntü üzerine görüntü ekledik
            cardView.fillSuperview()
        }
    }
    
    // MARK: -Fileprivate
    
    fileprivate func setupLayout() {
        let overallStackView = UIStackView(arrangedSubviews: [topStackView, cardsDeckView, buttonsStackView])
        overallStackView.axis = .vertical
        view.addSubview(overallStackView)
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        overallStackView.isLayoutMarginsRelativeArrangement = true
        overallStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        overallStackView.bringSubviewToFront(cardsDeckView)
        
    }

}

