//
//  EditRouteTableViewController.swift
//  Final1
//
//  Created by Misaa Pandaaa on 5/14/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import UIKit
import Firebase

class ChangeUnitTableViewController: UITableViewController {
    
    var unit = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Change unit"
        tableView.tableFooterView = UIView()
        fetchCurrentInfo()
    }
    
    func fetchCurrentInfo() {
        if let currentUser = Auth.auth().currentUser {
            let ref = FIRDatabaseReference.setting(uid: currentUser.uid).reference().child("unit")
            ref.observe(.value) { (snapshot) in
                let value = snapshot.value as? String ?? ""
                if value == "kilometer" {
                    self.unit = "kilometer"
                } else if value == "miles" {
                    self.unit = "miles"
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
        title.text = "Which unit do you prefer"
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
            cell.textLabel?.text = "Kilometer"
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "Miles"
        }
        
        if indexPath.row == 0 && unit == "kilometer" {
            cell.accessoryType = .checkmark
        } else if indexPath.row == 1 && unit == "miles" {
            cell.accessoryType = .checkmark
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        if let currentUser = Auth.auth().currentUser {
            let ref = FIRDatabaseReference.setting(uid: currentUser.uid).reference().child("unit")
            if indexPath.row == 0 {
                ref.setValue("kilometer")
            } else if indexPath.row == 1 {
                ref.setValue("miles")
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
