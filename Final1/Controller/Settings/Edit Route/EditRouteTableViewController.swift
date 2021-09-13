//
//  EditRouteTableViewController.swift
//  Final1
//
//  Created by Misaa Pandaaa on 5/14/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import UIKit
import Firebase

class EditRouteTableViewController: UITableViewController {

    var displayAll = true
    var displayUsersId = [String]()
    var displayUsers = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Route display"
        tableView.tableFooterView = UIView()
        fetchCurrentInfo()
    }
    
    func fetchCurrentInfo() {
        if let currentUser = Auth.auth().currentUser {
            let ref = FIRDatabaseReference.setting(uid: currentUser.uid).reference().child("route")
            ref.observe(.value) { (snapshot) in
                self.displayAll = true
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    let value = child.value as? NSDictionary
                    let displayOnMap = value!["displayOnMap"] as? String ?? ""
                    if displayOnMap == "no" {
                        self.displayAll = false
                    } else {
                        self.displayUsersId.append(child.key)
                    }
                }
                
                DispatchQueue.main.async {
                    let refUser = FIRDatabaseReference.root.reference().child("users")
                    refUser.observeSingleEvent(of: .value, with: { (snapshot) in
                        for child in snapshot.children.allObjects as! [DataSnapshot] {
                            for id in self.displayUsersId {
                                if child.key == id {
                                     if let dictionary = child.value as? [String: AnyObject] {
                                        let user = User(dictionary: dictionary)
                                        user.uid = child.key
                                        self.displayUsers.append(user)
                                    }
                                }
                            }
                        }
                    })
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of section
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        let title = UILabel()
        title.font = UIFont.boldSystemFont(ofSize: 16)
        title.textColor = .lightGray
        title.text = "Whose routes would you like to see in map?"
        view.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        //title.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        title.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
        return view
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if indexPath.row == 0 {
            cell.textLabel?.text = "All friends"
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "Customize"
        }
        
        if displayAll && indexPath.row == 0 {
            cell.accessoryType = .checkmark
        } else if !displayAll && indexPath.row == 1 {
            cell.accessoryType = .checkmark
        }
            
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        if indexPath.row == 0 {
            displayAllRoute()
        }
        if indexPath.row == 1 {
            let chooseFriend = ChooseRoute()
            for user in displayUsers {
                chooseFriend.selectUsers.append(user)
            }
            let navController = UINavigationController(rootViewController: chooseFriend)
            present(navController, animated: true, completion: nil)
        }
    }
    
    func displayAllRoute () {
        if let currentUser = Auth.auth().currentUser {
            let ref = FIRDatabaseReference.setting(uid: currentUser.uid).reference().child("route")
            ref.observe(.value) { (snapshot) in
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    ref.child(child.key).child("displayOnMap").setValue("yes")
                }
            }
        }
    }
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
