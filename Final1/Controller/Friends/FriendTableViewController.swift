//
//  ListFriendViewController.swift
//  Final1
//
//  Created by Misaa Pandaaa on 4/26/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import UIKit
import Firebase

class FriendTableViewController: BaseSearchTableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchController = UISearchController(searchResultsController: resultController)
        tableView.tableHeaderView = self.searchController.searchBar
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        self.searchController.searchResultsUpdater = self
        
        self.resultController.tableView.delegate = self
        self.resultController.tableView.dataSource = self
        self.resultController.tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        fetchUser()
        getFriendList()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectUser: User
        
        if tableView == self.tableView {
            selectUser = friends[indexPath.row]
        }
        else {
            selectUser = filterUsers[indexPath.row]
        }
        
        defineActionSheet(selectUser)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == resultController.tableView
        {
            return self.filterUsers.count
        }
        else
        {
            return self.friends.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user: User
        
        if tableView == resultController.tableView
        {
            user = self.filterUsers[indexPath.row]
        }
        else
        {
            user = friends[indexPath.row]
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        cell.textLabel?.text = user.displayedName
        cell.detailTextLabel?.text = user.email
        
        if let profileImageUrl = user.profileImageURL {
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
        return cell
    }


}

extension FriendTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
