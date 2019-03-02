//
//  CLLocationCoordinate2DExtension.swift
//  StudyAtlas
//
//  Created by Admin on 12/6/18.
//  Copyright © 2018 Jaime Park. All rights reserved.
//

import Foundation
import GoogleMaps

extension CLLocationCoordinate2D {
    /**
     Returns the distance in meters.
     */
    func distance(from: CLLocationCoordinate2D) -> CLLocationDistance {
        let destination=CLLocation(latitude:from.latitude,longitude:from.longitude)
        return CLLocation(latitude: latitude, longitude: longitude).distance(from: destination)
    }
}
