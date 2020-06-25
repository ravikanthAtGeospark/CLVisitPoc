//
//  LocationManager.swift
//  CLVisitPoc
//
//  Created by GeoSpark Mac 15 on 21/04/20.
//  Copyright © 2020 GeoSpark. All rights reserved.
//

import Foundation
import CoreLocation


public typealias MotionCurrentLocationCompletionhandler = (( _ location:CLLocation?,_ error:String?) -> Void)?

protocol LocationManagerDelegate {
    func updateLocation(_ location:CLLocation,desc:String,activity:String)
}
class LocationManager: NSObject {
    
    private var getCurrentLocationHandlerNew : MotionCurrentLocationCompletionhandler?
    
    private let regionString = "Region Monitoring"
    private let visitString = "Did Visit"
    private let significantString = "Significant Location"
    
    public static let sharedInstance = LocationManager()
    var delegate:LocationManagerDelegate?
    
    private let regionIdentifier = "GeosparkregionIdentifier"
    private let regionRadius:CLLocationDistance = 100
    private let lastLocationDefaults = "lastLocation"
    private let isFirstLocation = "isFirstLocation"
    
    private let locationManager = CLLocationManager()
    private var isRequestLocation:Bool  = false
    private var activityString:String = ""
    private var locationType:String = ""
    private var isUpdateLocation:Bool = false
    
    func startTracking(){
        Utilis.savePDFData("Initialized CLLocationManager 1")
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startMonitoringVisits()
        
    }
    
    func stopTracking(){
        Utilis.savePDFData("Stop CLLocationManager 1")
        locationManager.stopMonitoringVisits()
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
}

extension LocationManager:CLLocationManagerDelegate{
    
    // MARK:CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
     
        
        if checkIsFirst(){
            self.activityString = "W"
            Utilis.saveLogsMap(manager.location!, "SignificantLocation")
            self.updateLocation(location, self.significantString,"W")

        }else{
            if isSignificantLocationChanges(location) && isUpdateLocation == false{
                self.getCurrentLocationNew { (location, errorStatus) in
                    Utilis.saveLogsMap(manager.location!,self.regionString)
                    self.updateLocation(location!, self.significantString, "W")
                }
            }
        }
        
        if let getLocationCompletionHandler = self.getCurrentLocationHandlerNew {
                 getLocationCompletionHandler!(locations.last,nil)
                 return
             }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        self.activityString = "R"
        self.isUpdateLocation = true
        self.getCurrentLocationNew { (location, error) in
            self.isUpdateLocation = false
            Utilis.saveLogsMap(manager.location!,self.regionString)
            self.updateLocation(location!, self.regionString,"R")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        self.activityString = "S"
        self.isUpdateLocation = true
        self.getCurrentLocationNew { (location, error) in
            self.isUpdateLocation = false
            Utilis.saveLogsMap(manager.location!,self.regionString)
            self.updateLocation(location!,self.visitString,"S")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError",error)
    }
    
    // MARK: Create Geofence
    
    func createSingle(_ coordinate: CLLocationCoordinate2D){
        cleareGeofence()
        let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: coordinate.latitude,longitude: coordinate.longitude),radius:regionRadius,  identifier:regionIdentifier)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        locationManager.startMonitoring(for: region)
    }
    
    func cleareGeofence(){
        locationManager.monitoredRegions.forEach { region in
            locationManager.stopMonitoring(for: region)
        }
    }
    
    func updateLocation(_ location:CLLocation, _ desc:String,_ activity:String){
        saveLocation(location)
        createSingle(location.coordinate)
        delegate?.updateLocation(location, desc: desc, activity: activity)
        NotificationCenter.default.post(name: .newLocationSaved, object: self, userInfo: nil)
    }
    
    func saveLocation(_ location:CLLocation){
        UserDefaults.standard.set(location.coordinate.latitude, forKey: "latitude")
        UserDefaults.standard.set(location.coordinate.longitude, forKey: "longitude")
        UserDefaults.standard.set(location.horizontalAccuracy, forKey: "accuracy")
        UserDefaults.standard.set(location.timestamp, forKey: "timestamp")
        UserDefaults.standard.synchronize()
    }
    
    func getLastLocation() -> CLLocation?{
        Utilis.savePDFData("Checking for last Location")
        let lat = UserDefaults.standard.double(forKey: "latitude")
        let lng = UserDefaults.standard.double(forKey: "longitude")
        let time = UserDefaults.standard.object(forKey: "timestamp")
        let accuracy = UserDefaults.standard.double(forKey: "accuracy")
        
        if lat != 0.0 && lng != 0.0{
            let loc = CLLocation(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng), altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: 0, timestamp: time! as! Date)
            return loc
        }
        
        return CLLocation()
    }
    
    func checkIsFirst() -> Bool{
        let lastLocation = getLastLocation()
        let isFirst = UserDefaults.standard.bool(forKey: isFirstLocation)
        if isFirst == false{
            UserDefaults.standard.set(true, forKey: isFirstLocation)
            return true
        } else if lastLocation == nil{
            return true
        }else{
            return false
        }
        
    }
    func isSignificantLocationChanges( _ location:CLLocation) -> Bool{
        
        let lastLocation = getLastLocation()
        let timeDifference = location.timestamp.timeIntervalSince(lastLocation!.timestamp)
        let distanceDifference = location.distance(from: lastLocation!)
        let accuracyDifference = lastLocation!.horizontalAccuracy > location.horizontalAccuracy
        
        if timeDifference.minutes >= 5{
            return true
        } else if distanceDifference  > 300 {
            return true
        } else if accuracyDifference{
            return true
        }else{
            return false
        }
    }
    
    func getCurrentLocationNew(handler:MotionCurrentLocationCompletionhandler){
        locationManager.requestLocation()
        self.getCurrentLocationHandlerNew = handler
    }
    
}

extension LocationManager{
    
    func requestLocationOnce(){
        isRequestLocation = true
        let locationManager1 = CLLocationManager()
        locationManager1.delegate = self
        locationManager1.allowsBackgroundLocationUpdates = true
        locationManager1.pausesLocationUpdatesAutomatically = false
        locationManager1.requestLocation()
        Utilis.savePDFData("==========  Requesting location Once  ==========")
    }
    
}
struct LastLocation: Codable {
    
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var timeStamp: Date
    var altitude: CLLocationDistance
    var horizontalAccuracy:CLLocationAccuracy
    var verticalAccuracy:CLLocationAccuracy
    
    init(_ loca:CLLocation) {
        self.latitude = loca.coordinate.latitude
        self.longitude = loca.coordinate.longitude
        self.altitude = loca.altitude
        self.horizontalAccuracy = loca.horizontalAccuracy
        self.verticalAccuracy = loca.verticalAccuracy
        self.timeStamp = loca.timestamp
    }
}

