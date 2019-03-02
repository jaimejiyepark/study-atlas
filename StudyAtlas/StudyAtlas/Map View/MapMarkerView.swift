//
//  MapMarkerView.swift
//  StudyAtlas
//
//  Created by Shaifali Goyal on 11/27/18.
//  Copyright © 2018 Jaime Park. All rights reserved.
//

//https://medium.com/@matschmidy/how-to-implement-custom-and-dynamic-map-marker-info-windows-for-google-maps-ios-e9d993ef46d4

import UIKit

class MapMarkerView: UIView {

    weak var delegate : MapMarkerDelegate?
    @IBOutlet weak var siteLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    var siteData : NSDictionary?
    
    override func awakeFromNib() {
        let navyBlue = UIColor(red:0.00, green:0.28, blue:0.38, alpha:1.0).cgColor
        infoButton.makeRoundButton(navyBlue)
        self.layer.borderWidth = 1.0
        self.layer.borderColor = navyBlue
        
    }
    
    @IBAction func infoButtonClicked() {
        guard let data = siteData else {
            print("infoButton clicked but no data")
            return
        }
        delegate?.infoButtonClicked(data)
        print("info button clicked")
    }
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "MapMarkerView", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }
}

protocol MapMarkerDelegate : class {
    func infoButtonClicked(_ data: NSDictionary)
}
