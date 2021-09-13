//
//  StatisticTableViewController.swift
//  Final1
//
//  Created by Misaa Pandaaa on 5/15/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import UIKit

class StatisticTableViewController: UITableViewController{
    
    let cellId = "cellId"
    
    let values: [CGFloat] = [5, 10, 7]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
        setToCurrentTime()
        configureHeader()
        splitString()
        navigationItem.title = "Statistic"
        
    }
    var monday: Date!
    func getMonday(_ myDate: Date) -> Date {
        let cal = Calendar.current
        var comps = cal.dateComponents([.weekOfYear, .yearForWeekOfYear], from: myDate)
        comps.weekday = 2 // Monday
        let mondayInWeek = cal.date(from: comps)!
        monday = mondayInWeek
        return mondayInWeek
    }
    
    func getSunday(_ monday: Date) -> Date {
        let dateComponent = DateComponents(day: 6)
        let futureDate = Calendar.current.date(byAdding: dateComponent, to: monday)
        return futureDate!
    }
    
    var dateRangeStr = ""
    func getCurrentDateRange () {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = DateIntervalFormatter.Style.short
        formatter.timeStyle = DateIntervalFormatter.Style.none
        let dateRangeStr = formatter.string(from: monday, to: self.getSunday(monday))
        self.dateRangeStr = dateRangeStr
    }
    
    func setToCurrentTime() {
        monday = self.getMonday(Date())
        getCurrentMonth()
        getCurrentDateRange()
    }
    
    func increaseOneWeek() {
        let dateComponent = DateComponents(day: 7)
        monday = Calendar.current.date(byAdding: dateComponent, to: monday)
        //return futureDate!
    }
    
    func decreaseOneWeek() {
        let dayComp = DateComponents(day: -7)
        monday = Calendar.current.date(byAdding: dayComp, to: monday)
    }
    
    func increaseOneMonth() {
        let dayComp = DateComponents(month: 1)
        monday = Calendar.current.date(byAdding: dayComp, to: monday)
    }
    
    func decreaseOneMonth() {
        let dayComp = DateComponents(month: -1)
        monday = Calendar.current.date(byAdding: dayComp, to: monday)
    }
    var weekStr = ""
    func getCurrentMonth() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        let nameOfMonth = dateFormatter.string(from: monday)
        weekStr = nameOfMonth
    }
    
    func configureHeader () {
        let cell = tableView.dequeueReusableCell(withIdentifier: "statisticHeader") as!
        StatisticHeaderTableViewCell
        cell.dateMonth.text = self.dateRangeStr
        //cell.graph.register(UINib(nibName: "GraphViewController", bundle: nil), forCellWithReuseIdentifier: "GraphViewController")
        cell.segmentFunc = { [unowned self] in
            switch cell.segment.selectedSegmentIndex
            {
            case 0:
                self.setToCurrentTime()
                cell.dateMonth.text = self.dateRangeStr
            case 1:
                self.setToCurrentTime()
                cell.dateMonth.text = self.weekStr
            default:
                break
            }
            
        }
        cell.increaseFunc = { [unowned self] in
            switch cell.segment.selectedSegmentIndex
            {
            case 0:
                self.increaseOneWeek()
                self.getCurrentDateRange()
                cell.dateMonth.text = self.dateRangeStr
            case 1:
                self.increaseOneMonth()
                self.getCurrentMonth()
                cell.dateMonth.text = self.weekStr
            default:
                break
            }
        }
        cell.decreaseFunc = { [unowned self] in
            switch cell.segment.selectedSegmentIndex
            {
            case 0:
                self.decreaseOneWeek()
                self.getCurrentDateRange()
                cell.dateMonth.text = self.dateRangeStr
            case 1:
                self.decreaseOneMonth()
                self.getCurrentMonth()
                cell.dateMonth.text = self.weekStr
            default:
                break
            }
        }
        tableView.tableHeaderView = cell
        
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "routeListTableViewCell") as! RouteListTableViewCell
            
            return cell
        //}
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if let cell = cell as? RouteListTableViewCell {
                cell.routeCollectionView.dataSource = self
                cell.routeCollectionView.delegate = self
                cell.routeCollectionView.isScrollEnabled = false
                cell.routeCollectionView.reloadData()
                
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //if indexPath.row == 0 {
            return tableView.bounds.height + 50
        //}
        
    }
    
    var longtitude = ""
    var latitude = ""
    var time = ""
    var point = "<+10.72956120,+106.69377020> +/- 0.00m (speed -1.00 mps / course -1.00) @ 5/16/19, 11:47:39 PM Indochina Time"
    func splitString() {
        let start = point.index(point.startIndex, offsetBy: 1)
        var temp = 0
        for (index ,char) in point.enumerated() {
            if char == "," {
                temp = index
                break
            }
        }
        let end = point.index(point.startIndex, offsetBy: temp)
        longtitude = String(point.substring(with: start..<end))
        
    }
}

extension StatisticTableViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "routeCell", for: indexPath) as! RouteCollectionViewCell
        cell.contentView.layer.cornerRadius = 8.0
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true
        
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 0.5
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = 8.0
        layout.minimumInteritemSpacing = 4.0
        
        let numberOfItemsPerRow: CGFloat = 1.0
        let itemWidth = (collectionView.bounds.width - layout.minimumLineSpacing - 8) / numberOfItemsPerRow
        
        return CGSize(width: itemWidth, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
//    }

    
    
}
