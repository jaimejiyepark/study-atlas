//
//  Storage.swift
//  StudyAtlas
//
//  Created by Admin on 12/6/18.
//  Copyright © 2018 Jaime Park. All rights reserved.
//

import Foundation
import GoogleMaps

struct Storage {
    
    /**
     Store the last user location based on updates from the user.
     */
    static var lastUserLocation: CLLocationCoordinate2D? {
        get {
            let lat = UserDefaults.standard.double(forKey: "lastLatitude")
            let lon = UserDefaults.standard.double(forKey: "lastLongitude")
            
            print("Received stored location (lat: \(lat), lon: \(lon)")
            if(lat == 0.00 || lon == 0.00) {
                return nil
            }
            
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        set(lastUserLocation) {
            if let lat = lastUserLocation?.latitude, let lon = lastUserLocation?.longitude {
                UserDefaults.standard.set(lat, forKey: "lastLatitude")
                UserDefaults.standard.set(lon, forKey: "lastLongitude")
            }
        }
    }
}

