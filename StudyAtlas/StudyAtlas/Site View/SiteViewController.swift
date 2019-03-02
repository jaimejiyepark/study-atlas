//
//  siteViewController.swift
//  StudyAtlas
//
//  Created by Jacob Morris on 11/26/18.
//  Copyright © 2018 Jaime Park. All rights reserved.
//
import UIKit
import Foundation

class SiteViewController: UIViewController {
    var siteName : String? = "Silo"
    var updates : [[String : String]] = []
    @IBOutlet weak var siteNameLabel: UILabel!
    @IBOutlet weak var busyLabel: UILabel!
    @IBOutlet weak var siteTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSiteTableView()
    }
}

extension SiteViewController : UITableViewDelegate, UITableViewDataSource {
    /**
     Get count of updates
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("total count for table view")
        print(updates.count)
        return updates.count
    }
    
    /**
     Generate a single cell
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            as! SiteTableViewCell
        
        print("creating a cell for an update")
        let update = updates[indexPath.row]
        print("Path : ")
        print(indexPath.row)
        dump(update)
        print(update.keys)
        cell.floorLabel.text = "floor: " + String(describing: update["floor"] ?? "1")
        cell.roomLabel.text = "room: " + String(describing: update["room"] ?? "")
        cell.busynessLabel.text = "busy: " +  String(describing: update["busyness"] ?? "5")
        print(update["floor"] ?? "1")
        dump(cell)
        return cell
    }
    
    /**
     Setup datasource and delegates for the table view
     */
    func setupSiteTableView(){
        siteTableView.dataSource = self
        siteTableView.delegate = self
        siteTableView.rowHeight = 125
        
        guard let siteName = siteName else {
            print("No site name selected!")
            return
        }
        
        siteNameLabel.text = siteName
        
        Api.getUpdates(siteName) { (documents, _) in
            guard let updates = documents else {
                print("Network error")
                return
            }
            
            self.updates = updates as! [[String : String]]
            let totBusyness = updates.map {
                return Int($0["busyness"] as! String)!
                }.reduce(0, +)
            if updates.count > 0 {
                let avgBusiness = totBusyness / updates.count
                self.busyLabel.text = "busyness: " + String(avgBusiness)
            } else {
                self.busyLabel.text = "busyness: --"
            }
            
            self.siteTableView.reloadData()
        }
        
        siteNameLabel.text = siteName
    }
    
}
