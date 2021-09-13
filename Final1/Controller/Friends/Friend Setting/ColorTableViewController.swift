//
//  ColorTableViewController.swift
//  Final1
//
//  Created by Misaa Pandaaa on 5/14/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import UIKit
import Firebase

class ColorTableViewController: UITableViewController {

    var color = String()
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib.init(nibName: "ColorTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ColorTableViewCell")
        title = "Color on Map"
        fetchData()
    }
    
    func fetchData () {
        print(user.uid!)
        if let currentUser = Auth.auth().currentUser {
            let refColor = FIRDatabaseReference.setting(uid: currentUser.uid).reference().child("route").child(user.uid!).child("color")
            refColor.observe(.value) { (snapshot) in
                let value = snapshot.value as? String ?? ""
                self.color = value
                for (index, oneColor) in self.colorSet.enumerated() {
                    if oneColor == self.color {
                        self.colorChosen = index
                        print(index)
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 7
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }

    var colorSet = ["purple", "green", "magenta", "blue", "yellow", "cyan", "red"]
    var colorChosen : Int!
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ColorTableViewCell", for: indexPath) as! ColorTableViewCell
        
        if indexPath.row == 0 {
            cell.colorName.text = "Purple"
            cell.colorImage.image = UIImage(color: .purple)
        }
        else if indexPath.row == 1 {
            cell.colorName.text = "Green"
            cell.colorImage.image = UIImage(color: .green)
        }
        else if indexPath.row == 2 {
            cell.colorName.text = "Magenta"
            cell.colorImage.image = UIImage(color: .magenta)
        }
        else if indexPath.row == 3 {
            cell.colorName.text = "Blue"
            cell.colorImage.image = UIImage(color: .blue)
        }
        else if indexPath.row == 4 {
            cell.colorName.text = "Yellow"
            cell.colorImage.image = UIImage(color: .yellow)
        }
        else if indexPath.row == 5 {
            cell.colorName.text = "Cyan"
            cell.colorImage.image = UIImage(color: .cyan)
        }
        else if indexPath.row == 6 {
            cell.colorName.text = "Red"
            cell.colorImage.image = UIImage(color: .red)
        }
        if let index = colorChosen {
            if index == indexPath.row {
            //cell.accessoryType = .checkmark
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
            tableView.delegate?.tableView!(tableView, didSelectRowAt: indexPath)
            }}
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        colorChosen = indexPath.row
        if let currentUser = Auth.auth().currentUser {
            let refColor = FIRDatabaseReference.setting(uid: currentUser.uid).reference().child("route").child(user.uid!).child("color")
            refColor.setValue(colorSet[indexPath.row])
            
        }
    }
    

}
