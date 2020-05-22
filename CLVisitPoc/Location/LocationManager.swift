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
    
    func updateCurrentLocation(){
        let loca = CLLocationManager()
        loca.delegate = self
        self.isUpdateLocation = true
        loca.requestLocation()
    }
    
}

extension LocationManager:CLLocationManagerDelegate{
    
    // MARK:CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        if isUpdateLocation{
            updateLocation(location, "U","S")
            NotificationCenter.default.post(name: .newLocationSaved, object: self, userInfo: nil)
            Utilis.saveLogsMap(location, "Update Lcoation")
            return
        }
        
        if manager == locationManager {
            if isSignificantLocationChanges(location){
                Utilis.saveLogsMap(manager.location!, "SignificantLocation")
                self.requestLocationOnce()
                self.activityString = "W"
                Utilis.savePDFData("********  Requesting location for Significant ***********")
            }
        }else{
            if activityString == "R"{
                Utilis.savePDFData("------------ Precise location for Region Monitoring  ------------")
                locationType = regionString
            }else if activityString == "S"{
                Utilis.savePDFData("&&&&&&&&&&   Precise location for Vist  &&&&&&&&&&")
                locationType = visitString
            }else{
                Utilis.savePDFData("***********   Precise location for Significant Changes  ***********")
                locationType = significantString
                self.saveLocation(manager.location!)
            }
            NotificationCenter.default.post(name: .newLocationSaved, object: self, userInfo: nil)
            Utilis.saveLogsMap(location, "Precise location")
            updateLocation(location, locationType,activityString)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if manager == locationManager{
            Utilis.savePDFData("------------  Requesting location for Region Monitoring ---------------")
            self.activityString = "R"
            Utilis.saveLogsMap(manager.location!,regionString)
            self.requestLocationOnce()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        visit.A
        if manager == locationManager {
            self.activityString = "S"
            Utilis.savePDFData("&&&&&&&&&&  Requesting location for Visit  &&&&&&&&&&&&&&&&&&&&&&&&&")
            Utilis.saveLogsMap(manager.location!,visitString)
            self.requestLocationOnce()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError",error)
        Utilis.savePDFData("CLLocation Manager Error \(manager == locationManager) \("               ") )\(error.localizedDescription)")
    }
    
    // MARK: Create Geofence
    
    func createSingle(_ coordinate: CLLocationCoordinate2D){
        cleareGeofence()
        Utilis.savePDFData("==========  Creating Geofence  ==========")
        let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: coordinate.latitude,longitude: coordinate.longitude),radius:regionRadius,  identifier:regionIdentifier)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        locationManager.startMonitoring(for: region)
    }
    
    func cleareGeofence(){
        Utilis.savePDFData("==========  Clearing previous Geofence  ==========")

        locationManager.monitoredRegions.forEach { region in
            locationManager.stopMonitoring(for: region)
        }
    }
    
    func updateLocation(_ location:CLLocation, _ desc:String,_ activity:String){
        createSingle(location.coordinate)
        delegate?.updateLocation(location, desc: desc, activity: activity)
    }
    
    func saveLocation(_ location:CLLocation){
        Utilis.savePDFData("Saving Location")

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
    
    func isSignificantLocationChanges( _ location:CLLocation) -> Bool{

        Utilis.savePDFData("Checking is Significant Location")

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
            Utilis.savePDFData("Checking SignificantLocation Time \(timeDifference) Distance \(distanceDifference) Accuracy \(accuracyDifference)")

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

