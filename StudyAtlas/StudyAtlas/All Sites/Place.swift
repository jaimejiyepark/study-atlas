//
//  Place.swift
//  StudyAtlas
//
//  Created by Admin on 12/6/18.
//  Copyright © 2018 Jaime Park. All rights reserved.
//

import Foundation
import GoogleMaps

class Place {
    var name = String()
    var coord = CLLocationCoordinate2D()
    
    init(nam : String, coordinate : CLLocationCoordinate2D) {
        name = nam
        coord = coordinate
    }
}
