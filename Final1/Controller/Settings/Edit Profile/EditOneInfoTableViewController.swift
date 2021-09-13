

import UIKit
import Firebase

class EditOneInfoViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!

//    var myLabel: UILabel!
//    var myTextField: UITextField!
    var user = User()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(handleEdit))
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        label.text = title
        textField.delegate = self
        textField.becomeFirstResponder()
        textField.addTarget(self, action: #selector(didFill), for: .editingChanged)
        if (title == "Username") {
            readUsername()
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
            let content = textField.text, !content.isEmpty
            else {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                return
        }
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }

    @objc func handleEdit() {
        print("hehe")
        let ref = FIRDatabaseReference.users(uid: user.uid!).reference()
        if (title == "Name") {
            ref.child("displayedName").setValue(textField.text)
            user.displayedName = textField.text
            let alert = UIAlertController(title: nil, message: "Displayed name updated.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert,animated: true,completion: nil)
        } else if (title == "Username") {
            changeUsername(ref)
            user.username = textField.text
        } else if (title == "Email") {
            if let newEmail = textField.text {
                Auth.auth().currentUser?.updateEmail(to: newEmail) { (error) in
                    if error != nil {
                        print(error!)
                        self.handleError(error!)
                    } else {
                        self.didChangEmail()
                        ref.child("email").setValue(newEmail)
                        self.user.email = newEmail
                    }
                }
            }
            
            
        } else if (title == "Password") {
            if let newPass = textField.text {
                Auth.auth().currentUser?.updatePassword(to: newPass) { (error) in
                    if error != nil {
                        print(error!)
                        self.handleError(error!)
                    } else {
                        self.didChangePassword()
                    }
                }
            }
        }
        
    }
    
    var isExist = false
    var usernameArray = [String]()
    
    func readUsername() {
        FIRDatabaseReference.root.reference().child("users").observe(DataEventType.value) { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let value = child.value as? NSDictionary
                let usernameExist = value!["username"] as? String ?? ""
                self.usernameArray.append(usernameExist)
            }
        }
    }
    func changeUsername(_ ref: DatabaseReference) {
        
        for username in usernameArray {
            if (username == textField.text) {
                isExist = true
                break
            }
        }
        if isExist {
            print("alert")
            let alert = UIAlertController(title: "Error", message: "Your user ID is already in use", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert,animated: true,completion: nil)
            isExist = false
            return
        } else {
            ref.child("username").setValue(textField.text)
            usernameArray = []
            readUsername()
            let alert = UIAlertController(title: nil, message: "Username updated.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert,animated: true,completion: nil)
            
        }
    }
    
    func didChangePassword () {
        let alert = UIAlertController(title: nil, message: "Password updated", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    //Dismiss the keyboard when tapping outside of it
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textField.resignFirstResponder()
    }
    
    func didChangEmail() {
        let alert = UIAlertController(title: nil, message: "Email updated", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    //Dismiss the keyboard when pressing return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField.resignFirstResponder()
        
        view.endEditing(true)
        return false
    }
    
    var editInfo: EditProfileTableViewController?
    
    override func viewWillDisappear(_ animated: Bool) {
        editInfo?.user = user
        DispatchQueue.main.async(execute: {
            self.editInfo?.tableView.reloadData()
        })
    }

}
