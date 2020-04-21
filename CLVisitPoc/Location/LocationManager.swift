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
    func updateLocation(_ location:CLLocation,desc:String)
}
class LocationManager: NSObject {
    
    public static let sharedInstance = LocationManager()
    var delegate:LocationManagerDelegate?
    
    private let regionIdentifier = "GeosparkregionIdentifier"
    private let regionRadius:CLLocationDistance = 100
    private let lastLocationDefaults = "lastLocation"
    private let isFirstLocation = "isFirstLocation"
    
    private let locationManager = CLLocationManager()
    private var locationManager1:CLLocationManager?
    
    private var isRequestLocation:Bool  = false
    
    
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
        
        if isSignificantLocationChanges(location){
            UserDefaults.standard.removeObject(forKey: lastLocationDefaults)
            UserDefaults.standard.synchronize()
            self.saveLocation(location)
            updateLocation(location, "SignificantLocation")
        }else{
            if isRequestLocation && manager == locationManager1{
                isRequestLocation = false
                updateLocation(location, "SignificantLocation")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        self.requestLocationOnce()
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
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
    
    func updateLocation(_ location:CLLocation, _ desc:String){
        delegate?.updateLocation(location, desc: desc)
    }
    
    func saveLocation(_ location:CLLocation){
        let loc = LastLocation(location)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do{
            let data = try? encoder.encode(loc)
            UserDefaults.standard.set(data, forKey: lastLocationDefaults)
            UserDefaults.standard.synchronize()
        }
    }
    
    func getLastLocation() -> LastLocation?{
        var lastLocation:LastLocation?
        let locatData = UserDefaults.standard.data(forKey: lastLocationDefaults)
        if locatData == nil{
            return lastLocation
        }else{
            do{
             let decoder = JSONDecoder()
              return try? decoder.decode(LastLocation.self, from: locatData!)
            }
            catch{
                return lastLocation
            }
        }
    }
    
    func isSignificantLocationChanges( _ location:CLLocation) -> Bool{
        let lastLocation = getLastLocation()
        let isFirst = UserDefaults.standard.bool(forKey: isFirstLocation)
        if isFirst == false{
            UserDefaults.standard.set(true, forKey: isFirstLocation)
            return true
        } else if lastLocation == nil{
            return false
        }else{
            
            let lastLocationDetails = CLLocation(coordinate: CLLocationCoordinate2D(latitude: lastLocation!.latitude, longitude: lastLocation!.longitude), altitude: lastLocation!.altitude, horizontalAccuracy: lastLocation!.horizontalAccuracy, verticalAccuracy: lastLocation!.verticalAccuracy, timestamp: lastLocation!.timeStamp)
            
            let timeDifference = location.timestamp.timeIntervalSince(lastLocationDetails.timestamp)
            let distanceDifference = location.distance(from: lastLocationDetails)
            let accuracyDifference = location.horizontalAccuracy > lastLocationDetails.horizontalAccuracy
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
        self.isRequestLocation = true
        locationManager1 = CLLocationManager()
        locationManager1!.delegate = self
        locationManager1!.requestAlwaysAuthorization()
        locationManager1!.allowsBackgroundLocationUpdates = true
        locationManager1!.pausesLocationUpdatesAutomatically = false
        locationManager1!.requestLocation()
    }
    
    func requestLoctionStop(){
        locationManager1 = nil
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

