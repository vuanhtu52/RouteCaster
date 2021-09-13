//
//  ViewController.swift
//  SettingsTemplate
//
//  Created by Stephen Dowless on 2/10/19.
//  Copyright © 2019 Stephan Dowless. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "SettingsCell"

class FriendSettingTableViewController: UIViewController {
    
    // MARK: - Properties
    let logoutCell = "logoutCell"
    var tableView: UITableView!
    var userInfoHeader: UserInfoHeader!
    var user: User!
    var didDisplayOnMap = true
    var didAllowLocation = true
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        configureUI()
    }
    
    // MARK: - Helper Functions
    
    func fetchData() {
        if let currentUser = Auth.auth().currentUser {
        let ref = FIRDatabaseReference.setting(uid: currentUser.uid).reference().child("route").child(user.uid!).child("displayOnMap")
            ref.observe(.value) { (snapshot) in
                let value = snapshot.value as? String ?? ""
                if value == "yes" {
                    self.didDisplayOnMap = true
                } else {
                    self.didDisplayOnMap = false
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        let refLoca = FIRDatabaseReference.setting(uid: currentUser.uid).reference().child("route").child(user.uid!).child("allowed")
            refLoca.observe(.value) { (snapshot) in
                let value = snapshot.value as? String ?? ""
                if value == "yes" {
                    self.didAllowLocation = true
                } else {
                    self.didAllowLocation = false
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func configureTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        tableView.register(LogOutCell.self, forCellReuseIdentifier: logoutCell)
        tableView.register(SettingsCell.self, forCellReuseIdentifier: reuseIdentifier)
        view.addSubview(tableView)
        tableView.frame = view.frame
        
        let frame = CGRect(x: 0, y: 88, width: view.frame.width, height: 100)
        userInfoHeader = UserInfoHeader(frame: frame)
        userInfoHeader.emailLabel.text = user.email!
        userInfoHeader.usernameLabel.text = user.displayedName!
        if let profileImage = user.profileImageURL {
            userInfoHeader.profileImageView.loadImageUsingCacheWithUrlString(profileImage)
        }
        tableView.tableHeaderView = userInfoHeader
        tableView.tableFooterView = UIView()
    }
    
    func configureUI() {
        configureTableView()
        
//        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.barTintColor = UIColor(red: 202/255, green: 111/255, blue: 252/255, alpha: 1)
        navigationItem.title = "Settings"
    }
    
}

extension FriendSettingTableViewController: UITableViewDelegate, UITableViewDataSource {

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let section = SettingsSection(rawValue: section) else { return 0 }
        
        switch section {
        case .Map: return MapOption.allCases.count
        case .Location: return LocationOption.allCases.count
        case .Statistics: return StatisticsOption.allCases.count
        case .Unfriend: return UnfriendOption.allCases.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor(red: 202/255, green: 111/255, blue: 252/255, alpha: 1)
        
        print("Section is \(section)")
        
        let title = UILabel()
        title.font = UIFont.boldSystemFont(ofSize: 16)
        title.textColor = .white
        title.text = SettingsSection(rawValue: section)?.description
        view.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SettingsCell
        guard let section = SettingsSection(rawValue: indexPath.section) else { return UITableViewCell() }
        
        switch section {
        case .Map:
            let map = MapOption(rawValue: indexPath.row)
            cell.sectionType = map
        case .Location:
            let location = LocationOption(rawValue: indexPath.row)
            cell.sectionType = location
        case .Statistics:
            let statistics = StatisticsOption(rawValue: indexPath.row)
            cell.sectionType = statistics
        case .Unfriend:
            let unfriend = UnfriendOption(rawValue: indexPath.row)
            cell.sectionType = unfriend
        }
        
        if indexPath.section == 0 && indexPath.row == 0 {
            cell.switchControl.isOn = didDisplayOnMap
            cell.switchOn = { [unowned self] in
                self.visibleOnMap()
            }
            cell.switchOff = { [unowned self] in
                self.invisibleOnMap()
            }
        }
        else if indexPath.section == 0 && indexPath.row == 1 {
            cell.accessoryType = .disclosureIndicator
        }
        else if indexPath.section == 1 && indexPath.row == 0 {
            cell.switchControl.isOn = didAllowLocation
            cell.switchOn = { [unowned self] in
                self.allowLocation()
            }
            cell.switchOff = { [unowned self] in
                self.notAllowLocation()
            }
        }
        else if indexPath.section == 2 && indexPath.row == 0 {
            cell.accessoryType = .disclosureIndicator
        } else if indexPath.section == 3 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: logoutCell, for: indexPath) as! LogOutCell
            cell.textLabel?.text = "Unfriend"
            cell.textLabel?.textColor = UIColor.red
            cell.selectionStyle = .none
            
            return cell
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = SettingsSection(rawValue: indexPath.section) else { return }
        
        switch section {
        case .Map:
            if (indexPath.row == 1) {
                colorChange()
            }
        case .Location:
            return
        case .Statistics:
            viewStatistics()
        case .Unfriend:
            confirmUnfriend()
        }
    }
    
    func colorChange() {
        let color = ColorTableViewController()
        color.user = user
        self.navigationController?.pushViewController(color, animated: true)
    }
    
    func viewStatistics() {
        
    }
    
    func confirmUnfriend() {
        let alert = UIAlertController(title: nil, message: "Do you want to unfriend this person?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (okAction) in
            self.user.removeFriend()
            _ = self.navigationController?.popToRootViewController(animated: true)
        }
        alert.addAction(okAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func visibleOnMap () {
        if let currentUser = Auth.auth().currentUser {
            let ref = FIRDatabaseReference.setting(uid: currentUser.uid).reference().child("route").child(user.uid!).child("displayOnMap")
            ref.setValue("yes")
        }
    }
    
    func invisibleOnMap() {
        if let currentUser = Auth.auth().currentUser {
            let ref = FIRDatabaseReference.setting(uid: currentUser.uid).reference().child("route").child(user.uid!).child("displayOnMap")
            ref.setValue("no")
        }
    }
    
    func allowLocation() {
        if let currentUser = Auth.auth().currentUser {
            let ref = FIRDatabaseReference.setting(uid: currentUser.uid).reference().child("route").child(user.uid!).child("allowed")
            ref.setValue("yes")
        }
    }
    
    func notAllowLocation() {
        if let currentUser = Auth.auth().currentUser {
            let ref = FIRDatabaseReference.setting(uid: currentUser.uid).reference().child("route").child(user.uid!).child("allowed")
            ref.setValue("no")
        }
    }
}

