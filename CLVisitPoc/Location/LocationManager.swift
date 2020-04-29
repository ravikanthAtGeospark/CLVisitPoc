//
//  LocationManager.swift
//  CLVisitPoc
//
//  Created by GeoSpark Mac 15 on 21/04/20.
//  Copyright © 2020 GeoSpark. All rights reserved.
//

import Foundation
import CoreLocation


protocol LocationManagerDelegate {
    func updateLocation(_ location:CLLocation,desc:String,activity:String)
}
class LocationManager: NSObject {
    
    private let regionString = "Region Monitoring"
    private let visitString = "Did Visit"
    private let significantString = "Significant"
    
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
    
    
    func startTracking(){
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startMonitoringVisits()
        
    }
    
    func stopTracking(){
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
        
        if manager == locationManager {
            if isSignificantLocationChanges(location){
                saveLogs(manager.location!, "SignificantLocation")
                self.requestLocationOnce()
                self.activityString = "W"
            }
        }else{
            print("didUpdateLocations Precise" )
            if activityString == "R"{
                locationType = regionString
            }else if activityString == "S"{
                locationType = visitString
            }else{
                locationType = significantString
                self.saveLocation(manager.location!)
            }
            saveLogs(manager.location!, "Precise location ")
            updateLocation(location, locationType,activityString)
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if manager == locationManager{
            self.activityString = "R"
            saveLogs(manager.location!, "Region Monitoring ")
            self.requestLocationOnce()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        saveLogs(manager.location!,visitString)
        self.requestLocationOnce()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
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
        createSingle(location.coordinate)
        delegate?.updateLocation(location, desc: desc, activity: activity)
    }
    
    func saveLocation(_ location:CLLocation){
        UserDefaults.standard.set(location.coordinate.latitude, forKey: "latitude")
        UserDefaults.standard.set(location.coordinate.longitude, forKey: "longitude")
        UserDefaults.standard.set(location.horizontalAccuracy, forKey: "accuracy")
        UserDefaults.standard.set(location.timestamp, forKey: "timestamp")
        UserDefaults.standard.synchronize()
    }
    
    func getLastLocation() -> CLLocation?{
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
    
    func isSignificantLocationChanges( _ location:CLLocation) -> Bool{
        let lastLocation = getLastLocation()
        let isFirst = UserDefaults.standard.bool(forKey: isFirstLocation)
        if isFirst == false{
            UserDefaults.standard.set(true, forKey: isFirstLocation)
            return true
        } else if lastLocation == nil{
            return true
        }else{
            
            let timeDifference = location.timestamp.timeIntervalSince(lastLocation!.timestamp)
            let distanceDifference = location.distance(from: lastLocation!)
            let accuracyDifference = lastLocation!.horizontalAccuracy > location.horizontalAccuracy
            if timeDifference.minutes >= 5{
                return true
            }else if distanceDifference  > 300 {
                return true
            } else if accuracyDifference{
                return true
            }else{
                return false
            }
        }
        
    }
    
    func saveLogs(_ location:CLLocation,_ descr:String){
        
        let dataDictionary = ["desc":"\(descr ) \("     ") \(location.description)","timeStamp":currentTimestamp()]
        var dataArray = UserDefaults.standard.array(forKey: "GeoSparkKeyMapLocation")
        if let _ = dataArray {
            dataArray?.append(dataDictionary)
        }else{
            dataArray = [dataDictionary]
        }
        UserDefaults.standard.set(dataArray, forKey: "GeoSparkKeyMapLocation")
        UserDefaults.standard.synchronize()
    }
    
    func currentTimestamp() -> String {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MMM-dd HH:mm:ss"
        let date = Date()
        return dateFormatter.string(from: date)
    }

}

extension LocationManager{
    
    func requestLocationOnce(){
        let locationManager1 = CLLocationManager()
        locationManager1.delegate = self
        locationManager1.allowsBackgroundLocationUpdates = true
        locationManager1.pausesLocationUpdatesAutomatically = false
        locationManager1.requestLocation()
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

