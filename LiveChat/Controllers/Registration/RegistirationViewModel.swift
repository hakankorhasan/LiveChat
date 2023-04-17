//
//  RegistirationViewModel.swift
//  LiveChat
//
//  Created by Hakan Körhasan on 24.12.2022.
//

import UIKit
import Firebase

class RegistirationViewModel {
    
   /* var image: UIImage? {
        didSet {
            imageObservers?(image)
        }
    }*/
    
    // Reactive programming
    var bindableImage = Bindable<UIImage>()
    
    var bindableIsFormValid = Bindable<Bool>()
    
    var bindableIsRegistering = Bindable<Bool>()
    
    var fullName: String? {
        didSet {
            checkFromValidity()
        }
    }
    
    var email: String? { didSet { checkFromValidity() } }
    
    var password: String? { didSet { checkFromValidity() } }
    
    func checkFromValidity() {
        let isFormValid = fullName?.isEmpty == false && email?.isEmpty == false && password?.isEmpty == false && bindableImage.value != nil
        bindableIsFormValid.value = isFormValid
        //isFormValidObservers?(isFormValid)
    }
    
    
    func performRegistering(completion: @escaping (Error?) -> ()) {
        
        guard let email = email, let password = password else { return}
        bindableIsRegistering.value = true
        
        Auth.auth().createUser(withEmail: email, password: password) { (res, error) in
            
            if let error = error {
                completion(error)
                return
            }
            
            print("successfully registered user", res?.user.uid ?? "")
            
            // upload images to firebase
            self.saveImageToFirebase(completion: completion)
            
        }
    }
    
    fileprivate func saveInfoToFirestore(imageUrl: String, completion: @escaping (Error?) ->()) {
        
        let uid = Auth.auth().currentUser?.uid ?? ""
        let docData = [
            "fullname": fullName ?? "",
            "uid": uid,
            "age": 18,
            "minSeekingAge": SettingsController.defaultMinSeekingAge,
            "maxSeekingAge": SettingsController.defaultMaxSeekingAge,
            "imageUrl1": imageUrl] as [String: Any]
        
        Firestore.firestore().collection("users").document(uid).setData(docData) { (error) in
            print("error üstü")
            if let error = error {
                completion(error)
              print("error")
                return
            }
            print(docData)
            completion(nil)
        }
    }
    
    fileprivate func saveImageToFirebase(completion: @escaping (Error?) -> ()) {
        
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
        let imageData = self.bindableImage.value?.jpegData(compressionQuality: 0.75) ?? Data()
        ref.putData(imageData) { (_, error) in
            
            if let error = error {
                completion(error)
                return
            }
            
            print("Finished uploading image to storage")
            ref.downloadURL { url, error in
                if let error = error {
                    completion(error)
                    return
                }
                
                self.bindableIsRegistering.value = false
                print("download url of our images is:", url?.absoluteString ?? "")
                
                let imageURL = url?.absoluteString ?? ""
                self.saveInfoToFirestore(imageUrl: imageURL, completion: completion)
            }
        }
    }
    
   
    
}
