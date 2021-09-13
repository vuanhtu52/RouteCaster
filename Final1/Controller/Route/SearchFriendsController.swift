//
//  searchFreidnsController.swift
//  Final1
//
//  Created by Sung Jin, Kim  on 5/15/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import UIKit
import GoogleMaps

class SearchFriendsController: BaseSearchTableViewController {
    // There are using for passing the data from home to friendsRouteInfo
    var startPoint = CLLocation()
    var endPoint = CLLocation()
    var userID:String = ""
    
    var selectUser: User!
    var filterFriends: [User]!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        print("VIEW FRIEND ROUTE")
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "friendsRouteInfo"){
            if let friendRoute = segue.destination as? FriendsRouteInfoController{
                friendRoute.startPoint = startPoint
                friendRoute.endPoint = endPoint
                friendRoute.userID = userID
            }
        }
    }
    
    // Update table view based on the search content
    override func updateSearchResults(for searchController: UISearchController) {
        self.filterFriends = friends.filter({ (user: User) -> Bool in
            let searchContent = searchController.searchBar.text!.lowercased()
            let name = user.displayedName!.lowercased()
            let email = user.email!.lowercased()
            if name.contains(searchContent) || email.contains(searchContent)
            {
                return true
            }
            else
            {
                return false
            }
            
        })
        
        self.resultController.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == self.tableView {
            selectUser = friends[indexPath.row]
        }
        else {
            selectUser = filterFriends[indexPath.row]
        }
        userID = selectUser.uid!
        self.performSegue(withIdentifier: "friendsRouteInfo", sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == resultController.tableView
        {
            return self.filterFriends.count
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
            user = self.filterFriends[indexPath.row]
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
