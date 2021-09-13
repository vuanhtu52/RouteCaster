//
//  ViewController.swift
//  Final1
//
//  Created by Misaa Pandaaa on 4/20/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Auth.auth().addStateDidChangeListener({(auth, user) in
            if user != nil {    // Have user
                
            }
            else {
                
            }
        })
    }

}

