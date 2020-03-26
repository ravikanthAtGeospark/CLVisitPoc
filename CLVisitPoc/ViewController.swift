//
//  ViewController.swift
//  CLVisitPoc
//
//  Created by GeoSpark Mac 15 on 26/03/20.
//  Copyright © 2020 GeoSpark. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate{

    
    @IBOutlet weak var trackingBtn: UIButton!
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func startMonitoringVisits() {
         locationManager.delegate = self
         locationManager.requestAlwaysAuthorization()
         locationManager.startMonitoringSignificantLocationChanges()
         locationManager.allowsBackgroundLocationUpdates = true
         locationManager.pausesLocationUpdatesAutomatically = false
         locationManager.startMonitoringVisits()
         locationManager.requestLocation()
     }
         
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        LoggerManager.sharedInstance.writeLocationToFile("\(error.localizedDescription)")
        print("didFailWithError",error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUpdateLocations",locations.last!)
        LoggerManager.sharedInstance.writeLocationToFile("\(String(describing: locations.last?.description))  \("     significant")")
        saveVisits(locations.last!.coordinate, "significant")
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        print("didVisit",visit)
        LoggerManager.sharedInstance.writeLocationToFile("\(String(describing: visit.description))  \("     visits")")
        saveVisits(visit.coordinate, "visits")
    }
    
    
    func saveVisits(_ location: CLLocationCoordinate2D,_ source:String){
        
        let dataDictionary = ["latitude" : location.latitude, "longitude" : location.longitude,"timeStamp" : currentTimestampWithHours(),"source":source] as [String : Any]
        var dataArray = UserDefaults.standard.array(forKey: "GeoSparkKeyForLatLongInfo")
        if let _ = dataArray {
            dataArray?.append(dataDictionary)
        }else{
            dataArray = [dataDictionary]
        }
        UserDefaults.standard.set(dataArray, forKey: "GeoSparkKeyForLatLongInfo")
        UserDefaults.standard.synchronize()
    }
    
    func currentTimestampWithHours() -> String {
          let dateFormatter : DateFormatter = DateFormatter()
          dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
          let date = Date()
          return dateFormatter.string(from: date)
      }

    
    @IBAction func startTracking(_ sender: Any) {
        startMonitoringVisits()
     }
     
     @IBAction func showLogs(_ sender: Any) {
        let vc = LogsViewController.viewController()
        self.navigationController?.pushViewController(vc, animated: false)
        
     }
}

