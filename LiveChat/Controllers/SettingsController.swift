import UIKit
import FirebaseFirestore
import FirebaseAuth
import SDWebImage
import JGProgressHUD
import FirebaseStorage

protocol SettingsControllerDelegate {
    func didSaveSettings()
}

class CustomImagePickerController: UIImagePickerController {
    var imageButton: UIButton?
}

class SettingsController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var delegate: SettingsControllerDelegate?
    
    // instance properties
    lazy var image1Button = createButton(selector: #selector(handleSelectPhoto))
    lazy var image2Button = createButton(selector: #selector(handleSelectPhoto))
    lazy var image3Button = createButton(selector: #selector(handleSelectPhoto))
    
    @objc func handleSelectPhoto(button: UIButton) {
        print("Select photo with button:", button)
        let imagePicker = CustomImagePickerController()
        imagePicker.delegate = self
        imagePicker.imageButton = button
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[.originalImage] as? UIImage
        // how do i set the image on my buttons when I select a photo?
        let imageButton = (picker as? CustomImagePickerController)?.imageButton
        imageButton?.setImage(selectedImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        dismiss(animated: true)
        
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
        guard let uploadData = selectedImage?.jpegData(compressionQuality: 0.75) else { return }
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Upload image..."
        hud.show(in: view)
        ref.putData(uploadData) { (nil, err) in
            hud.dismiss()
            if let err = err {
                print("error uploading image", err)
                return
            }
            print("uploading image")
            
            ref.downloadURL { (url, err) in
                if let err = err {
                    print("Failed download url", err)
                    return
                }
                
                print("images url", url?.absoluteString ?? "")
                
                if imageButton == self.image1Button {
                    self.user?.imageUrl1 = url?.absoluteString
                } else if imageButton == self.image2Button {
                    self.user?.imageUrl2 = url?.absoluteString
                } else {
                    self.user?.imageUrl3 = url?.absoluteString
                }
            }
            
        }
    }
    
    func createButton(selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Select Photo", for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        return button
    }
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItems()
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .interactive
        
        fetchCurrentUser()
    }
    
    fileprivate func fetchCurrentUser() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        db.collection("users").document(uid).getDocument { snapshot, err in
            
            if let err = err {
                print(err)
                return
            }
            
            guard let dictionary = snapshot?.data() else { return }
            self.user = User(dictionary: dictionary)
            self.loadUserPhotos()
            
            self.tableView.reloadData()
        }
    }
    
    fileprivate func loadUserPhotos() {
        
        if let imageUrl = user?.imageUrl1, let url = URL(string: imageUrl) {
            
            SDWebImageManager.shared.loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.image1Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
        
        if let imageUrl = user?.imageUrl2, let url = URL(string: imageUrl) {
            
            SDWebImageManager.shared.loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.image2Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
        
        if let imageUrl = user?.imageUrl3, let url = URL(string: imageUrl) {
            
            SDWebImageManager.shared.loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.image3Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
        
    }
    
    
    lazy var header: UIView = {
        let header = UIView()
        header.addSubview(image1Button)
        let padding: CGFloat = 16
        image1Button.anchor(top: header.topAnchor, leading: header.leadingAnchor, bottom: header.bottomAnchor, trailing: nil, padding: .init(top: padding, left: padding, bottom: padding, right: 0))
        image1Button.widthAnchor.constraint(equalTo: header.widthAnchor, multiplier: 0.45).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [image2Button, image3Button])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = padding
        
        header.addSubview(stackView)
        stackView.anchor(top: header.topAnchor, leading: image1Button.trailingAnchor, bottom: header.bottomAnchor, trailing: header.trailingAnchor, padding: .init(top: padding, left: padding, bottom: padding, right: padding))
        return header
    }()
    
    class HeaderLabel: UILabel {
        override func drawText(in rect: CGRect) {
            super.drawText(in: rect.insetBy(dx: 16, dy: 0))
        }
    
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return header
        }
        let headerLabel = HeaderLabel()
        
        switch section {
        case 1:
            headerLabel.text = "Name"
        case 2:
            headerLabel.text = "Profession"
        case 3:
            headerLabel.text = "Age"
        case 4:
            headerLabel.text = "Bio"
        default:
            headerLabel.text = "Seeking Age Range"
        }
        headerLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return headerLabel
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 300
        }
        return 20
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 0 : 1
    }
    
    @objc fileprivate func handleChangeMin(slider: UISlider) {
        let indexPath = IndexPath(row: 0, section: 5)
        let ageRangeCell = tableView.cellForRow(at: indexPath) as? AgeRangeCell
        ageRangeCell?.minLabel.text = "Min: \(Int(slider.value))"
        self.user?.minSeekingAge = (Int(slider.value))
    }
    
    @objc fileprivate func handleChangeMax(slider: UISlider) {
        let indexPath = IndexPath(row: 0, section: 5)
        let ageRangeCell = tableView.cellForRow(at: indexPath) as? AgeRangeCell
        ageRangeCell?.maxLabel.text = "Max: \(Int(slider.value))"
        self.user?.maxSeekingAge = (Int(slider.value))
    }
    
    static let defaultMinSeekingAge: Int = 18
    static let defaultMaxSeekingAge: Int = 60
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 5 {
            let ageRangeCell = AgeRangeCell(style: .default, reuseIdentifier: nil)
            ageRangeCell.minSliderBar.addTarget(self, action: #selector(handleChangeMin), for: .valueChanged)
            ageRangeCell.maxSliderBar.addTarget(self, action: #selector(handleChangeMax), for: .valueChanged)
            
            let minAge = user?.minSeekingAge ?? SettingsController.defaultMinSeekingAge
            let maxAge = user?.maxSeekingAge ?? SettingsController.defaultMaxSeekingAge
            
            ageRangeCell.minLabel.text = "Min: \(minAge)"
            ageRangeCell.maxLabel.text = "Max: \(maxAge)"
            ageRangeCell.minSliderBar.value = Float(minAge)
            ageRangeCell.maxSliderBar.value = Float(maxAge)
            return ageRangeCell
        }
        
        let cell = SettingsCell(style: .default, reuseIdentifier: nil)
        
        switch indexPath.section {
        case 1:
            cell.textField.placeholder = user?.name?.isEmpty == true ? "Enter Name" : user?.name
            cell.textField.addTarget(self, action: #selector(handleNameChanged), for: .editingChanged)
        case 2:
            cell.textField.placeholder = user?.profession?.isEmpty == true ? "Enter Profession" : user?.profession
            cell.textField.addTarget(self, action: #selector(handleProfessionChanged), for: .editingChanged)
        case 3:
            if let age = user?.age {
                cell.textField.placeholder = age == -1 ? "Enter Age" : String(age)
            }
            cell.textField.addTarget(self, action: #selector(handleAgeChanged), for: .editingChanged)
        default:
            cell.textField.placeholder = user?.bio?.isEmpty == true ? "Enter Bio" : user?.bio
        }
        
        return cell
    }
    
    @objc fileprivate func handleNameChanged(textField: UITextField) {
        self.user?.name = textField.text
    }
    
    @objc fileprivate func handleProfessionChanged(textField: UITextField) {
        self.user?.profession = textField.text
    }
    
    @objc fileprivate func handleAgeChanged(textField: UITextField) {
        self.user?.age = Int(textField.text ?? "")
    }
    
    fileprivate func setupNavigationItems() {
        navigationItem.title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave)),
            UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        ]
    }
    
    var homeController: HomeController?
    
    @objc fileprivate func handleSave() {
       

        guard let uid = Auth.auth().currentUser?.uid else { return }
        print(uid)
        let docData: [String: Any] = [
            "uid": uid,
            "fullName": user?.name ?? "",
            "profession": user?.profession ?? "",
            "bio": user?.bio ?? "",
            "imageUrl1": user?.imageUrl1 ?? "",
            "imageUrl2": user?.imageUrl2 ?? "",
            "imageUrl3": user?.imageUrl3 ?? "",
            "age": user?.age ?? -1,
            "minSeekingAge": user?.minSeekingAge ?? -1,
            "maxSeekingAge": user?.maxSeekingAge ?? -1
        ]
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Saving Settings..."
        hud.show(in: view)
        Firestore.firestore().collection("users").document(uid).setData(docData) { (err) in
            hud.dismiss(animated: true)
            if let err = err {
                print("error saving", err)
                return
            }
            
            print("Finished")
        }
        
        self.dismiss(animated: true) {
            self.delegate?.didSaveSettings()
            //self.homeController?.fetchCurrentUser()
        }
    }
    
    @objc fileprivate func handleLogout() {
        try? Auth.auth().signOut()
        dismiss(animated: true)
        
    }
    
    @objc fileprivate func handleCancel() {
        dismiss(animated: true)
    }

}