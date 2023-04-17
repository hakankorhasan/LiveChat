//
//  LoginController.swift
//  LiveChat
//
//  Created by Hakan Körhasan on 6.04.2023.
//

import UIKit
import JGProgressHUD

protocol LoginControllerDelegate {
    func didFinishLoggingIn()
}

class LoginController: UIViewController {
    
    var delegate: LoginControllerDelegate?
    
    let emailTextField: CustomTextField = {
        let tf = CustomTextField(padding: 16)
        tf.layer.cornerRadius = 24
        tf.backgroundColor = .white
        tf.placeholder = "Enter Your Email"
        tf.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tf.heightAnchor.constraint(equalToConstant: 50).isActive = true
        tf.keyboardType = .emailAddress
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return tf
    }()
    
    let passwordTextField: CustomTextField = {
        let tf = CustomTextField(padding: 16)
        tf.placeholder = "Enter Your Password"
        tf.layer.cornerRadius = 24
        tf.backgroundColor = .white
        tf.heightAnchor.constraint(equalToConstant: 50).isActive = true
        tf.isSecureTextEntry = true
        tf.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return tf
    }()
    
    let loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Login", for: .normal)
        btn.layer.cornerRadius = 24
        btn.backgroundColor = .lightGray
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btn.setTitleColor(.gray, for: .disabled)
        btn.isEnabled = false
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        btn.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return btn
    }()
    
    let backToRegisterButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Back to Register", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        btn.addTarget(self, action: #selector(handleBackRegister), for: .touchUpInside)
        return btn
    }()
    
    @objc fileprivate func handleBackRegister() {
        navigationController?.popViewController(animated: true)
    }
    
    lazy var verticalStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [
            emailTextField,
            passwordTextField,
            loginButton
        ])
        sv.axis = .vertical
        sv.spacing = 8
        sv.distribution = .fillEqually
        return sv
    }()
    
    fileprivate let loginViewModel = LoginViewModel()
    fileprivate let loginHUD = JGProgressHUD(style: .dark)
    
    fileprivate func setupBindables() {
        loginViewModel.isFromValid.bind { [unowned self] (isFromValid) in
            guard let isFromValid = isFromValid else { return }
            self.loginButton.isEnabled = isFromValid
            self.loginButton.backgroundColor = isFromValid ? #colorLiteral(red: 0.2622437775, green: 0.263807416, blue: 0.4489398003, alpha: 1) : .lightGray
            self.loginButton.setTitleColor(isFromValid ? .white : .gray, for: .normal)
        }
        
        loginViewModel.isSignIn.bind { [unowned self] (isRegistering) in
            if isRegistering == true {
                self.loginHUD.textLabel.text = "Register"
                self.loginHUD.show(in: self.view)
            } else {
                self.loginHUD.dismiss()
            }
        }
    }
    
    @objc fileprivate func handleLogin() {
        loginViewModel.performLogin { err in
            self.loginHUD.dismiss()
            if let err = err {
                print("login error", err)
                return
            }
            
            self.dismiss(animated: true) {
                self.delegate?.didFinishLoggingIn()
            }
            print("successfully registered")
        }
    }
    
    @objc fileprivate func handleTextChange(textfield: UITextField) {
        if textfield == emailTextField {
            loginViewModel.email = textfield.text
        } else {
            loginViewModel.password = textfield.text
        }
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setupGradientLayer()
        setupLayout()
        
        setupNotificatiionObservers()
        setupTapGesture()
        
        setupBindables()
    }
    
    fileprivate func setupTapGesture() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss)))
    }
    
    @objc fileprivate func handleTapDismiss() {
        self.view.endEditing(true) //dismiss keyboard
    }
    
    fileprivate func setupNotificatiionObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @objc fileprivate func handleKeyboardShow(notification: Notification) {
        guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = value.cgRectValue
        
        let bottomSpace = view.frame.height - verticalStackView.frame.origin.y - verticalStackView.frame.height
        print(bottomSpace)
        
        let difference = keyboardFrame.height - bottomSpace
        self.view.transform = CGAffineTransform(translationX: 0, y: -difference - 8)
    }
    
    @objc fileprivate func handleKeyboardHide() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.view.transform = .identity
        }
        
    }
    
    
    let gradientLayer = CAGradientLayer()
    
    fileprivate func setupLayout() {
        view.addSubview(verticalStackView)
        verticalStackView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 50, bottom: 0, right: 50))
        
        verticalStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.addSubview(backToRegisterButton)
        backToRegisterButton.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
    }
    

    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    fileprivate func setupGradientLayer() {
        let topColor = UIColor(#colorLiteral(red: 0.0007543815882, green: 0.0007543815882, blue: 0.00075438153, alpha: 1))
        let bottomColor = UIColor(#colorLiteral(red: 0.2622437775, green: 0.263807416, blue: 0.4489398003, alpha: 1))
        
        gradientLayer.colors = [bottomColor.cgColor, topColor.cgColor]
        gradientLayer.locations = [0, 1]
        view.layer.addSublayer(gradientLayer)
        gradientLayer.frame = view.bounds
    }
    
    
}
