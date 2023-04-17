//
//  SwipingPhotosControllerViewController.swift
//  LiveChat
//
//  Created by Hakan Körhasan on 10.04.2023.
//

import UIKit

class SwipingPhotosController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var cardViewModel: CardViewModel! {
        didSet {
            print(cardViewModel.attributedString)
            controllers = cardViewModel.imageNames.map({ (imageUrls) in
                let photoController = PhotoController(imageUrl: imageUrls)
                return photoController
            })
            
            setViewControllers([controllers.first!], direction: .forward, animated: false)
            
            setupBarView()
        }
    }
    
    fileprivate let barStackView = UIStackView(arrangedSubviews: [])
    fileprivate let deSelectedBarColor = UIColor(white: 0, alpha: 0.1)
    
    fileprivate func setupBarView() {
        cardViewModel.imageNames.forEach { (_) in
            let barView = UIView()
            barView.backgroundColor = deSelectedBarColor
            barView.layer.cornerRadius = 2
            barStackView.addArrangedSubview(barView)
        }
        
        barStackView.arrangedSubviews.first?.backgroundColor = .white
        var paddingTop: CGFloat = 8
        if !isCardViewMode {
            paddingTop += UIApplication.shared.statusBarFrame.height
        }
        barStackView.spacing = 4
        barStackView.distribution = .fillEqually
        view.addSubview(barStackView)
        barStackView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: paddingTop, left: 8, bottom: 8, right: 8), size: .init(width: 0, height: 4))
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        let currentPhotoController = viewControllers?.first
        if let index = controllers.firstIndex(where: {$0 == currentPhotoController}) {
            barStackView.arrangedSubviews.forEach({$0.backgroundColor = deSelectedBarColor})
            barStackView.arrangedSubviews[index].backgroundColor = .white
        }
        
    }
    
    var controllers = [UIViewController]()
    
    fileprivate let isCardViewMode: Bool
    
    // default olarak değer verilirse çağırıldığı sınıfta bu nesneye değer atama yapıp yapmamakta özgürüz
    //yani isCardViewMode: Bool diyerek tanımlasaydık let swipingPhotosController = SwipingPhotosController(isCardViewMode: true)
    //burayı doldurmamız gerekecekti şimdi ise let swipingPhotosController = SwipingPhotosController() bu şekilde kullanılabilir
    init(isCardViewMode: Bool = false) {
        self.isCardViewMode = isCardViewMode
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        dataSource = self
        view.backgroundColor = .white
        
        if isCardViewMode {
            disableSwipingTransition()
        }
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        
    }
    
    @objc fileprivate func handleTap(gesture: UITapGestureRecognizer) {
        let currentController = viewControllers!.first!
        
        if let index = controllers.firstIndex(of: currentController) {
            
            barStackView.arrangedSubviews.forEach({$0.backgroundColor = deSelectedBarColor})

            
            if gesture.location(in: self.view).x > view.frame.width / 2 {
                let nextIndex = min(index + 1, controllers.count - 1)
                let nextController = controllers[nextIndex]
                setViewControllers([nextController], direction: .forward, animated: false)
                barStackView.arrangedSubviews[nextIndex].backgroundColor = .white
            } else {
                let prevIndex = max(0, index - 1)
                let prevController = controllers[prevIndex]
                setViewControllers([prevController], direction: .forward, animated: false)
                barStackView.arrangedSubviews[prevIndex].backgroundColor = .white
            }
            
        }
    }
    
    fileprivate func disableSwipingTransition() {
        view.subviews.forEach { (v) in
            if let v = v as? UIScrollView {
                v.isScrollEnabled = false
            }
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = self.controllers.firstIndex(where: {$0 == viewController}) ?? 0
        if index == self.controllers.count - 1 { return nil }
        return controllers[index + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = self.controllers.firstIndex(where: {$0 == viewController}) ?? 0
        if index == 0 { return nil }
        return controllers[index - 1]
        
    }
    
}

class PhotoController: UIViewController {
    
    let imageView = UIImageView(image: #imageLiteral(resourceName: "kelly1"))
    
    init(imageUrl: String) {
        if let url = URL(string: imageUrl) {
            imageView.sd_setImage(with: url)
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        imageView.fillSuperview()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
