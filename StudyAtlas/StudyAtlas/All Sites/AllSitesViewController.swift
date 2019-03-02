//
//  allSitesViewController.swift
//  StudyAtlas
//
//  Created by Jacob Morris on 12/5/18.
//  Copyright © 2018 Jaime Park. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import GoogleMaps

class AllSitesViewController: UIViewController {
    @IBOutlet weak var allSitesTableView: UITableView!
    
    var places : [Place] = []
    var siteName : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAllSitesTableView()
    }
}

extension AllSitesViewController : UITableViewDelegate, UITableViewDataSource {
    /**
     Get the number of places in the table
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("total count for table view")
        print(places.count)
        return places.count
    }
    
    /**
     Generate the cell for each of the elements in places
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "allSiteCell", for: indexPath)
            as! AllSitesTableCell
        
        let update = places[indexPath.row].name
        cell.siteName.text = update
        
        return cell
    }
    
    /**
     On click of a table view cell, segue to view that displays information about the site
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        siteName = places[(indexPath.row)].name
        performSegue(withIdentifier: "allSitesToSiteView", sender: self)
    }
    
    /**
     Segue to new viewß
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "allSitesToSiteView") {
            let destination = segue.destination as! SiteViewController
            destination.siteName = siteName
        }
    }
    
    
    /**
     Setup view
    */
    func setupAllSitesTableView() {
        allSitesTableView.dataSource = self
        allSitesTableView.delegate = self
        
        Api.getCollection("places") { (documents, error) in
            if let documents = documents {
                for place in documents {
                    guard let name = place["name"] as? String else {
                        continue
                    }
                    guard let coord = place["coordinates"] as? GeoPoint else {
                        continue
                    }
                    
                    self.places.append(Place(nam: name, coordinate: CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)))
                }
                
                if let lastLocation = Storage.lastUserLocation {
                    self.places.sort { pl1, pl2 in
                        let dist1 = pl1.coord.distance(from: lastLocation)
                        let dist2 = pl2.coord.distance(from: lastLocation)
                        return dist1 < dist2
                    }
                    print("sorted locations")
                }
                self.allSitesTableView.reloadData()
                return
            }
            print("could not get places")
        }
    }
}
