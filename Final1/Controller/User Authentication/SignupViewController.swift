//
//  SignupViewController.swift
//  Final1
//
//  Created by Misaa Pandaaa on 4/24/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import UIKit
import Firebase

class SignupViewController: UIViewController, UITextFieldDelegate {
    
    struct Storyboard {
        static let showHome = "showHome"
        static let showTutorial = "showTutorial"
    }

    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var createAccountBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("sign up")
        createAccountBtn.isEnabled = false
        [displayNameTextField, emailTextField, usernameTextField, passwordTextField].forEach {
            $0?.addTarget(self, action: #selector(didFill), for: .editingChanged)
        }
    }
    
    @objc func didFill(_ textField: UITextField) {
        // Discard all whitespaces
        if (textField.text?.count == 1) {
            if (textField.text?.first == " ") {
                textField.text = ""
            }
        }
        
        guard
            let email = emailTextField.text, !email.isEmpty,
            let password = passwordTextField.text, !password.isEmpty,
            let displayName = displayNameTextField.text, !displayName.isEmpty,
            let username = usernameTextField.text, !username.isEmpty

            else {
                createAccountBtn.isEnabled = false
                return
            }
        createAccountBtn.isEnabled = true
    }
    

    @IBAction func createAccountDidTap(_ sender: Any) {
        var isExist = false
        let email = self.emailTextField.text!
        let username = self.usernameTextField.text!
        let name = self.displayNameTextField.text!
        let password = self.passwordTextField.text!
        
        var userLatitude = ""
        var userLongtitude = ""
        var userRouteURL = ""
        
        FIRDatabaseReference.root.reference().child("users").observe(DataEventType.value) { (snapshot) in
//            if (snapshot.hasChild(username)) {
//
//                print ("uid exists")
//                let alert = UIAlertController(title: "Error", message: "Your user ID is already in use", preferredStyle: .alert)
//                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//                alert.addAction(okAction)
//                self.present(alert,animated: true,completion: nil)
//                return
//            }
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let value = child.value as? NSDictionary
                let usernameExist = value!["username"] as? String ?? ""
                if (usernameExist == username) {
                    isExist = true
                }
            }
        }
            if isExist {
                let alert = UIAlertController(title: "Error", message: "Your user ID is already in use", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert,animated: true,completion: nil)
                return
            }
            else {
                Auth.auth().createUser(withEmail: email, password: password) { (firUser, error) in
                    print("in create user")
                    // save user's information
                    if error != nil {
                        print(error!._code)
                        self.handleError(error!)
                        return
                    }
                    else {
                        // Create and save basic information of user
                        guard let _ = firUser else {return}
                        print("create user no error")
                        let profileImage = UIImage(named: "download")!
                        let newUser = User(username: username, uid: Auth.auth().currentUser!.uid, displayedName: name, email: email, profileImage: profileImage, userLongtitude: userLongtitude, userLatitude: userLatitude, userRouteURL: userRouteURL)
                        
                        // Set default setting info
                        let refSetting = FIRDatabaseReference.setting(uid: Auth.auth().currentUser!.uid).reference()
                        let settingValue = [
                            "unit" : "kilometer",
                            "display": "nameava"
                        ]
                        refSetting.setValue(settingValue)

                        
                        
                        // Set default profile image
                        let firImage = ProfileImage(image: profileImage)
                        let resizedImage = firImage.image.resize()
                        if let imageData = resizedImage.jpegData(compressionQuality: 0.9) {
                            // 1. get the reference
                            // Each user will have only 1 profile picture
                            firImage.ref = FIRStorageReference.profileImages.referene().child(username)
                            
                            // 2. save that to the reference
                            firImage.ref.putData(imageData, metadata: nil, completion: { (_, err) in
                                
                                if let error = error {
                                    print(error)
                                    return
                                }
                                
                                firImage.ref.downloadURL(completion: { (url, err) in
                                    if let err = err {
                                        print(err)
                                        return
                                    }
                                    
                                    guard let url = url else { return }
                                    newUser.profileImageURL = url.absoluteString
                                    newUser.save()
                                    self.signIn(email, password)
                                })
                                
                            })
                        }
                    }
                    
                }
            
        }
        
    }
    func signIn (_ email: String, _ password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (firUser, error) in
            if let error = error {
                print(error._code)
                self.handleError(error)
                return
            } else {
                let baseSearch = BaseSearchTableViewController()
                baseSearch.fetchUser()
                baseSearch.getFriendList()
                self.performSegue(withIdentifier: Storyboard.showTutorial, sender: nil)
            }
        }
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
