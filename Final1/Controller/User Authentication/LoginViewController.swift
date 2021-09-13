//
//  LoginViewController.swift
//  Final1
//
//  Created by Misaa Pandaaa on 4/24/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loginBtn.isEnabled = false
        [nameTextField, passwordTextField].forEach {
            $0?.addTarget(self, action: #selector(didFill), for: .editingChanged)
        }
        nameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    @objc func didFill(_ textField: UITextField) {
        // Discard all whitespaces
        if (textField.text?.count == 1) {
            if (textField.text?.first == " ") {
                textField.text = ""
            }
        }
        guard
            let name = nameTextField.text, !name.isEmpty,
            let password = passwordTextField.text, !password.isEmpty
        else {
            loginBtn.isEnabled = false
            return
        }
        loginBtn.isEnabled = true
    }
    static var email = ""

    @IBAction func endEditName(_ sender: Any) {
        var userId = ""
        if (nameTextField.text!.contains("@")) {
            LoginViewController.email = nameTextField.text!
        }
        else {
            userId = nameTextField.text!
            print("userID " + userId)
            if userId != "" {
                FIRDatabaseReference.root.reference().child("users").observeSingleEvent(of: .value) { (snapshot) in
//                    if (snapshot.hasChild(userId)) {
//                        let value = snapshot.value as? NSDictionary
//                        let user = value?[userId] as? NSDictionary
//                        LoginViewController.email = user?["email"] as? String ?? ""
//                    }
                    for child in snapshot.children.allObjects as! [DataSnapshot] {
                        let value = child.value as? NSDictionary
                        let uid = value?["username"] as? String ?? ""
                        print(uid)
                        if userId == uid {
                            LoginViewController.email = value?["email"] as? String ?? ""
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func LogInDidTap(_ sender: Any) {
        
        let password = passwordTextField.text!
        
        Auth.auth().signIn(withEmail: LoginViewController.email, password: password) { (firUser, error) in
            if let error = error {
                self.handleError(error)
                return
            } else {
                let baseSearch = BaseSearchTableViewController()
                baseSearch.fetchUser()
                baseSearch.getFriendList()
                self.performSegue(withIdentifier: "showHome", sender: nil)
            }
        }
    }
    
    //Dismiss the keyboard when tapping outside of it
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        nameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    //Dismiss the keyboard when pressing return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        view.endEditing(true)
        return false
    }
}
