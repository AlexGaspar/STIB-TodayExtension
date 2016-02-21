//
//  TodayViewController.swift
//  Next-Metro
//
//  Created by Alex Gaspar on 15/02/16.
//  Copyright © 2016 Alex Gaspar. All rights reserved.
//

import UIKit
import NotificationCenter
import QuartzCore
import CoreLocation
import BrightFutures

class TodayViewController: UITableViewController, NCWidgetProviding, CLLocationManagerDelegate  {
    var activityIndicator = UIActivityIndicatorView()
    var locationManager: CLLocationManager!
    var IncommingMetro =  [Metro]()
    var current_lat = Double()
    var current_long = Double()
    var promise: Future<[Metro], NoError>!
    
    func addActivityIndicator() {
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 15)
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        addActivityIndicator()
        self.preferredContentSize = CGSizeMake(self.preferredContentSize.width, 42.0);
    }
    
    // Location manager
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSLog("error => %@ ", error)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        let location = locations.last
        
        current_lat = (location?.coordinate.latitude)!
        current_long = (location?.coordinate.longitude)!
        
        self.promise = IncomingList.getIncomingList(IncomingList.getClosetStation(current_lat, long: current_long))
    
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print(status == .AuthorizedWhenInUse)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        print("widgetPerformUpdateWithCompletionHandler")
        self.locationManager.startUpdatingLocation()
        
        self.promise.onSuccess { list in
            self.IncommingMetro = list
            self.activityIndicator.removeFromSuperview()
            self.tableView.reloadData()
            
            completionHandler(NCUpdateResult.NewData)
        }.onFailure { error in
            print("Something went wrong...")
            print(error)
            completionHandler(NCUpdateResult.NoData)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.preferredContentSize = CGSizeMake(self.preferredContentSize.width, (CGFloat(self.IncommingMetro.count) * 40.0) - 5.0);
        
        return IncommingMetro.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Metro Cell", forIndexPath: indexPath) as! MetroCell
        let metro = IncommingMetro[indexPath.row]
        
        return cell.setCellWithData(metro.getTimeLeft(), line: metro.getFormatedLineNumber(), name: metro.direction, color: metro.getColor().CGColor)
    }
}
