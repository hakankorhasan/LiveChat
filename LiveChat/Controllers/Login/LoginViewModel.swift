//
//  LoginViewModel.swift
//  LiveChat
//
//  Created by Hakan Körhasan on 6.04.2023.
//

import UIKit
import Firebase

class LoginViewModel {
    
    var isFromValid = Bindable<Bool>()
    var isSignIn = Bindable<Bool>()
    
    var email: String? { didSet { checkFromValidity() } }
    
    var password: String? { didSet { checkFromValidity() } }
    
    fileprivate func checkFromValidity() {
        let isValid = email?.isEmpty == false && password?.isEmpty == false
        isFromValid.value = isValid
    }
    
    func performLogin(completion: @escaping (Error?) -> ()) {
        guard let email = email, let password = password else { return }
        isSignIn.value = true
        Auth.auth().signIn(withEmail: email, password: password) { (res, err)  in
            completion(err)
        }
        
    }
}

