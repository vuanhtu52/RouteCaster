//
//  MainSettingViewController.swift
//  Final1
//
//  Created by Misaa Pandaaa on 4/24/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import UIKit
import Firebase

class MainSettingViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    struct Storyboard {
        static let showWelcome = "showWelcome"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func changeAvaDidTap(_ sender: Any) {
        handleSelectProfileImageView()
    }
    @IBAction func LogOutDidTap(_ sender: Any) {
        let alert = UIAlertController(title: "Logout", message: "Do you want to log out?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (okAction) in
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                self.performSegue(withIdentifier: Storyboard.showWelcome, sender: nil)
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        }
        alert.addAction(okAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }

}
