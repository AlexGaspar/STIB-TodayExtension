//
//  GeoHelper.swift
//  STIB-widget
//
//  Created by Alex Gaspar on 17/02/16.
//  Copyright © 2016 Alex Gaspar. All rights reserved.
//

import Foundation

class GeoHelper {
    static let earthRaduis = 6378.0
    
    class func degToRadian(coord: Double) -> Double {
        return (coord * M_PI) / 180
    }
    
    class func getDistanceBetween2Coord(l: Double, lo: Double, l2: Double, lo2: Double) -> Double {
        let lat = self.degToRadian(l)
        let long = self.degToRadian(lo)
        let lat2 = self.degToRadian(l2)
        let long2 = self.degToRadian(lo2)
        
        return acos(
            (sin(lat) * sin(lat2))
                + cos(lat) * cos(lat2) * cos(long - long2)
            ) * earthRaduis
    }
    
}

//return Math.Acos(
//    Math.Sin(lat1)*Math.Sin(lat2) +
//        Math.Cos(lat1)*Math.Cos(lat2)*Math.Cos(lon2 - lon1)
//    )*r;