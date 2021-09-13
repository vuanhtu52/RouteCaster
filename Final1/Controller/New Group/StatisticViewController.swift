//
//  StatisticViewController.swift
//  Final1
//
//  Created by Misaa Pandaaa on 5/16/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import UIKit

class StatisticViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var routeArr = ["Route 1", "Route 2", "Route 3", "Route 4", "Route 5"]
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return routeArr.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.graphCollectionView {
            let cell: BarChartCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "barChartCell", for: indexPath) as! BarChartCollectionViewCell
            return cell
        } else {
            let cell: RouteCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "routeCell", for: indexPath) as! RouteCollectionViewCell
            cell.routeName = routeArr[indexPath.row]
            return cell
        }
    }
    

    @IBOutlet weak var routeCollectionView: UICollectionView!
    @IBOutlet weak var graphCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        graphCollectionView.delegate = self
        graphCollectionView.dataSource = self
        routeCollectionView.delegate = self
        routeCollectionView.dataSource = self
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
