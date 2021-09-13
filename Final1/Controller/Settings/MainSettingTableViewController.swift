//
//  MainSettingTableViewController.swift
//  Final1
//
//  Created by Misaa Pandaaa on 5/9/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import UIKit
import Firebase
class MainSettingTableViewController: UITableViewController {
    
    var userInfoHeader: UserInfoHeader!
    let settingCell = "settingCell"
    let logoutCell = "logoutCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LogOutCell.self, forCellReuseIdentifier: logoutCell)
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        //tableView.backgroundColor = UIColor.white
        configureNav()
        configureHeader()
    }
    
    func configureHeader () {
        let frame = CGRect(x: 0, y: 88, width: view.frame.width, height: 100)
        if let currentUser = Auth.auth().currentUser {
            FIRDatabaseReference.users(uid: currentUser.uid).reference().observeSingleEvent(of: .value) { (snapshot) in
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                let user = User(dictionary: dictionary)
                self.userInfoHeader = UserInfoHeader(frame: frame)
                self.userInfoHeader.emailLabel.text = user.email!
                self.userInfoHeader.usernameLabel.text = user.displayedName!
                if let profileImage = user.profileImageURL {
                    self.userInfoHeader.profileImageView.loadImageUsingCacheWithUrlString(profileImage)
                }
                self.tableView.tableHeaderView = self.userInfoHeader
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        self.centerTableView()
    }
    
    func logOutFunc() {
        let alert = UIAlertController(title: "Logout", message: "Do you want to log out?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (okAction) in
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                self.performSegue(withIdentifier: "showWelcome", sender: nil)
                //let login = LoginViewController()
                //self.present(login, animated: true, completion: nil)
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        }
        alert.addAction(okAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func editProfileFunc() {
        let editProfile = EditProfileTableViewController()
        navigationController?.pushViewController(editProfile, animated: true)
    }
    
    func editRouteFunc() {
        let editRoute = EditRouteTableViewController()
        navigationController?.pushViewController(editRoute, animated: true)
    }
    
    func changeUnitFunc() {
        let changeUnit = ChangeUnitTableViewController()
        navigationController?.pushViewController(changeUnit, animated: true)
    }
    
    func customMarkerFunc() {
        let customMarker = CustomMarkerTableViewController()
        navigationController?.pushViewController(customMarker, animated: true)
    }
    
    func privacyFunc() {
        let privacy = PrivacyTableViewController()
        navigationController?.pushViewController(privacy, animated: true)
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {return 1}
        if section == 1 {return 3}
        if section == 2 {return 1}
        if section == 3 {return 1}
        if section == 4 {return 1}
        
        return 0
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 4) && (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: logoutCell, for: indexPath) as! LogOutCell
            cell.textLabel?.text = "Log out"
            cell.textLabel?.textColor = UIColor.red
            return cell
        } else {
            let cell = UITableViewCell()
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            if (indexPath.section == 0) && (indexPath.row == 0) { cell.textLabel?.text = "Edit Profile" }
            if (indexPath.section == 1) && (indexPath.row == 0) { cell.textLabel?.text = "Route display" }
            if (indexPath.section == 1) && (indexPath.row == 1) { cell.textLabel?.text = "Change unit" }
            if (indexPath.section == 1) && (indexPath.row == 2) { cell.textLabel?.text = "Custom marker" }
            if (indexPath.section == 2) && (indexPath.row == 0) { cell.textLabel?.text = "Location setting" }
            if (indexPath.section == 3) && (indexPath.row == 0) { cell.textLabel?.text = "View tutorial" }
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath.section == 0) && (indexPath.row == 0) {
           editProfileFunc()
        }
        if (indexPath.section == 1) && (indexPath.row == 0) {
            editRouteFunc()
        }
        if (indexPath.section == 1) && (indexPath.row == 1) {
            changeUnitFunc()
        }
        if (indexPath.section == 1) && (indexPath.row == 2) {
            customMarkerFunc()
        }
        if (indexPath.section == 2) && (indexPath.row == 0) {
            privacyFunc()
        }
        if (indexPath.section == 3) && (indexPath.row == 0) {
            self.performSegue(withIdentifier: "showTutorial", sender: nil)
        }
        if (indexPath.section == 4) && (indexPath.row == 0) {
            logOutFunc()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 4) {
            return 0
        }
        return 30
    }
    
//    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        if (section == 4) {
//            return 0
//        }
//        return 30
//    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor(red: 202/255, green: 111/255, blue: 252/255, alpha: 1)
        let title = UILabel()
        title.font = UIFont.boldSystemFont(ofSize: 16)
        title.textColor = .white
        if section == 0 {title.text = "Account"}
        if section == 1 {title.text =  "Map"}
        if section == 2 {title.text =  "Privacy"}
        if section == 3 {title.text =  "Tutorial"}
        view.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        
        return view
    }
    
}


extension UITableViewController {
    
    func centerTableView() {
        
        let contentSize = tableView.contentSize
        let boundsSize = tableView.bounds.size
        
        if contentSize.height < boundsSize.height {
            
            let yOffset = floor(boundsSize.height - contentSize.height) / 2
            
            tableView.contentOffset = CGPoint(x:0, y: -yOffset)
        }
    }
}
