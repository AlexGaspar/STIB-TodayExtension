//
//  IncomingList.swift
//  STIB-widget
//
//  Created by Alex Gaspar on 15/02/16.
//  Copyright © 2016 Alex Gaspar. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SWXMLHash
import BrightFutures

extension String {
    var hexColor: UIColor {
        let hex = self.stringByTrimmingCharactersInSet(NSCharacterSet.alphanumericCharacterSet().invertedSet)
        var int = UInt32()
        NSScanner(string: hex).scanHexInt(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return UIColor.clearColor()
        }
        return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

class Metro {
    var lineNumber: Int8
    var timeLeft: Int8
    var direction: String
    
    init(lineNumber: String, timeLeft: String, direction: String) {
        self.lineNumber = Int8(lineNumber)!
        self.timeLeft = Int8(timeLeft)!
        self.direction = direction
    }
    
    func getFormatedLineNumber() -> String {
        return " " + String(lineNumber) + " "
    }
    
    func getTimeLeft() -> String {
        return String(timeLeft) + " minutes"
    }
    
    func getColor() -> UIColor {
        switch (self.lineNumber) {
        case 1:
            return "#B92C92".hexColor
        case 5:
            return "#E6B012".hexColor
        default:
            return "#00ff00".hexColor
        }
    }
}

class ClosetStation {
    var distance = Double()
    var ids = [Int]()
    
    init(distance: Double, ids: [Int]) {
        self.distance = distance
        self.ids = ids
    }
}

class Station {
    var ids = [Int]()
    var long = Double()
    var lat = Double()
    
    init(ids: [Int], long: Double, lat: Double) {
        self.ids = ids
        self.long = long
        self.lat = lat
    }
}

class IncomingList {
    static var stationList = [
        Station(ids: [8282,8283], long: 4.341, lat: 50.855),
        Station(ids: [8211,8212], long: 4.404, lat: 50.828),
    ]
    
    class func getClosetStation(lat: Double, long: Double) -> [Int] {
        var closetStation = ClosetStation(distance: 99999.0, ids: [0])
        
        for station in stationList {
            let distance = GeoHelper.getDistanceBetween2Coord(lat, lo: long, l2: station.lat, lo2: station.long)
            if distance < closetStation.distance {
                closetStation = ClosetStation(distance: distance, ids: station.ids)
            }
        }
        
        return closetStation.ids
    }
    
    class func getIncomingMetros(stationId: Int) -> Future <[Metro], NoError> {
        let promise = Promise<[Metro], NoError>()
        var list = [Metro]()
        
        Alamofire.request(.GET, "http://m.stib.be/api/getwaitingtimes.php", parameters: ["halt": stationId])
            .response { (request, response, data, error) in
                let xml = SWXMLHash.parse(data!)
                
                for metro in xml["waitingtimes"]["waitingtime"] {
                    list.append(Metro(lineNumber: (metro["line"].element?.text)!, timeLeft: (metro["minutes"].element?.text)!, direction: (metro["destination"].element?.text)!))
                }
                
                promise.success(list)
        }
        
        return promise.future
    }
    
    class func getIncomingList(stationIds: [Int]) -> Future<[Metro], NoError>  {
        let promise = Promise<[Metro], NoError>()
        var promises = [Future<[Metro], NoError>]()
        
        for id in stationIds {
            promises.append( getIncomingMetros(id) )
        }
        
        // Wait until all requests to the STIB API are done
        promises.sequence().onSuccess  { (lists) in
            promise.success(lists.flatMap { $0 })
        }
        
        return promise.future
    }
}