//
//  RegistrationController.swift
//  LiveChat
//
//  Created by Hakan Körhasan on 23.12.2022.
//

import UIKit
import Firebase
import JGProgressHUD

extension RegistrationController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as? UIImage
        registrationViewModel.bindableImage.value = image
        registrationViewModel.checkFromValidity()
        //registrationViewModel.image = image
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
}

class RegistrationController: UIViewController {

    var delegate: LoginControllerDelegate?

    let selectPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 16
        button.backgroundColor = .white
        button.setTitle("Select Photo", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        button.heightAnchor.constraint(equalToConstant: 275).isActive = true
        button.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        return button
    }()
    
    lazy var selectPhotoButtonWidthAnchor = selectPhotoButton.widthAnchor.constraint(equalToConstant: 275)
    lazy var selectPhotoButtonHeightAnchor = selectPhotoButton.heightAnchor.constraint(equalToConstant: 275)
    
    @objc fileprivate func handleSelectPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    let fullNameTextField: UITextField = {
        let textField = CustomTextField(padding: 16)
        textField.layer.cornerRadius = 24
        textField.backgroundColor = .white
        textField.placeholder = "Enter full name"
        textField.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        textField.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return textField
    }()
    
    let emailTextField: UITextField = {
        let textField = CustomTextField(padding: 16)
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 24
        textField.placeholder = "Enter email"
        textField.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        textField.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        return textField
    }()
    
    let passwordTextField: UITextField = {
        let textField = CustomTextField(padding: 16)
        textField.placeholder = "Enter password"
        textField.layer.cornerRadius = 24
        textField.backgroundColor = .white
        textField.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        textField.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        textField.isSecureTextEntry = true
        return textField
    }()
    
    let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 24
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .lightGray
        button.setTitleColor(.gray, for: .disabled)
        button.isEnabled = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        return button
    }()
    
    let goToLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Go to Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.addTarget(self, action: #selector(handleGotoLogin), for: .touchUpInside)
        return button
    }()
    
    let registerHUD = JGProgressHUD(style: .dark)
    
    @objc fileprivate func handleGotoLogin() {
        print("tapped")
        let loginController = LoginController()
        navigationController?.pushViewController(loginController, animated: true)
    }
    
    @objc fileprivate func handleRegister(){
        self.handleTapDismiss()
        registrationViewModel.performRegistering { [weak self] (error) in
            if let error = error {
                self?.showHudWithError(error: error)
                return
            }
            self?.dismiss(animated: true) {
                self?.delegate?.didFinishLoggingIn()
            }
        }
    }
    
    fileprivate func showHudWithError(error: Error) {
        registerHUD.dismiss() // alertın sonlanmasını sağlar
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "failed register"
        hud.detailTextLabel.text = error.localizedDescription
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 4)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGradientlayer()
        
        setupLayout() // stackview sayfaya ortalandı
        
        setupNotificationObservers()
        
        setupTapGesture()
        
        setupRegistrationViewModelObserver()
    }
    
    // MARK:- Private
    
    let registrationViewModel = RegistirationViewModel()
    
    fileprivate func setupRegistrationViewModelObserver() {
        
        registrationViewModel.bindableIsFormValid.bind { (isFormValid) in
            guard let isFormValid = isFormValid else { return }
            self.registerButton.isEnabled = isFormValid
            if isFormValid {
                self.registerButton.setTitleColor(.white, for: .normal)
                self.registerButton.backgroundColor = UIColor(#colorLiteral(red: 0.2622437775, green: 0.263807416, blue: 0.4489398003, alpha: 1))
            } else {
                self.registerButton.setTitleColor(.gray, for: .disabled)
                self.registerButton.backgroundColor = .lightGray
            }
        }
        
        registrationViewModel.bindableImage.bind { (image) in
            self.selectPhotoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        registrationViewModel.bindableIsRegistering.bind { [unowned self] (isRegistering) in
            if isRegistering == true {
                registerHUD.textLabel.text = "Register"
                registerHUD.show(in: view)
            }else {
                registerHUD.dismiss()
            }
        }
    }
    
    
    @objc fileprivate func handleTextChange(textField: UITextField) {
        if textField == fullNameTextField {
            registrationViewModel.fullName = textField.text
        }else if textField == emailTextField {
            registrationViewModel.email = textField.text
        }else {
            registrationViewModel.password = textField.text
        }
      
    }
    
    fileprivate func setupTapGesture() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss)))
    }
        
    @objc fileprivate func handleTapDismiss() {
        self.view.endEditing(true) // dismisses keyboard
    }
    
    fileprivate func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
           // NotificationCenter.default.removeObserver(self) // you'll have a retain cycle
    }
        
    @objc fileprivate func handleKeyboardHide() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.view.transform = .identity
        })
    }
        
    @objc fileprivate func handleKeyboardShow(notification: Notification) {
        // how to figure out how tall the keyboard actually is
        guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = value.cgRectValue
           
        // let's try to figure out how tall the gap is from the register button to the bottom of the screen
        let bottomSpace = view.frame.height - overallStackView.frame.origin.y - overallStackView.frame.height
        print(bottomSpace)
            
        let difference = keyboardFrame.height - bottomSpace
        self.view.transform = CGAffineTransform(translationX: 0, y: -difference - 8)
    }
    
    
    lazy var verticalStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [
            fullNameTextField,
            emailTextField,
            passwordTextField,
            registerButton
        ])
        sv.axis = .vertical
        sv.distribution = .fillEqually
        sv.spacing = 8
        return sv
    }()
       
    lazy var overallStackView = UIStackView(arrangedSubviews: [
        selectPhotoButton,
        verticalStackView
    ])
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if self.traitCollection.verticalSizeClass == .compact {
            overallStackView.axis = .horizontal
            verticalStackView.distribution = .fillEqually
           // selectPhotoButtonHeightAnchor.isActive = false
            //selectPhotoButtonWidthAnchor.isActive = true
        }else{
            overallStackView.axis = .vertical
            verticalStackView.distribution = .fill
           // selectPhotoButtonHeightAnchor.isActive = false
           // selectPhotoButtonWidthAnchor.isActive = true
        }
    }
    
    
    fileprivate func setupLayout()  {
    navigationController?.isNavigationBarHidden = true
    view.addSubview(overallStackView)
        overallStackView.axis = .vertical
        overallStackView.spacing = 8
        //selectPhotoButton.widthAnchor.constraint(equalToConstant: 275).isActive = true
        overallStackView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 50, bottom: 0, right: 50))
        overallStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.addSubview(goToLoginButton)
        goToLoginButton.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
    }
    
    let gradientLayer = CAGradientLayer()
    
    // gürünümü değiştirince backgroundColor yeni ekrana uyum sağlar
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    fileprivate func setupGradientlayer() {
        let topColor = UIColor(#colorLiteral(red: 0.0007543815882, green: 0.0007543815882, blue: 0.00075438153, alpha: 1))
        let bottomColor = UIColor(#colorLiteral(red: 0.2622437775, green: 0.263807416, blue: 0.4489398003, alpha: 1))
        gradientLayer.colors = [bottomColor.cgColor, topColor.cgColor]
        gradientLayer.locations = [0, 1]
        view.layer.addSublayer(gradientLayer)
        gradientLayer.frame = view.bounds
    }

}
