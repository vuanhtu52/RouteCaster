//
//  EditRouteTableViewController.swift
//  Final1
//
//  Created by Misaa Pandaaa on 5/14/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import UIKit
import Firebase

class CustomMarkerTableViewController: UITableViewController {
    
    var display = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Custom marker"
        tableView.tableFooterView = UIView()
        fetchCurrentInfo()
    }
    
    func fetchCurrentInfo() {
        if let currentUser = Auth.auth().currentUser {
            let ref = FIRDatabaseReference.setting(uid: currentUser.uid).reference().child("display")
            ref.observe(.value) { (snapshot) in
                let value = snapshot.value as? String ?? ""
                if value == "name" {
                    self.display = "name"
                } else if value == "ava" {
                    self.display = "ava"
                } else if value == "nameava" {
                    self.display = "nameava"
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
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
        return 3
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
        title.text = "Which info will display on your friend marker?"
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
            cell.textLabel?.text = "Display name"
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "Display avatar"
        } else if indexPath.row == 2 {
            cell.textLabel?.text = "Display both name and avatar"
        }
        
        if indexPath.row == 0 && display == "name" {
            cell.accessoryType = .checkmark
        } else if indexPath.row == 1 && display == "ava" {
            cell.accessoryType = .checkmark
        } else if indexPath.row == 2 && display == "nameava" {
            cell.accessoryType = .checkmark
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        if let currentUser = Auth.auth().currentUser {
            let ref = FIRDatabaseReference.setting(uid: currentUser.uid).reference().child("display")
            if indexPath.row == 0 {
                ref.setValue("name")
            } else if indexPath.row == 1 {
                ref.setValue("ava")
            } else if indexPath.row == 2 {
                ref.setValue("nameava")
            }
        }
    }
    
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
