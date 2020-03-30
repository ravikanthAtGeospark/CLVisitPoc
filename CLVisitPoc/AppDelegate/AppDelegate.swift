//
//  AppDelegate.swift
//  CLVisitPoc
//
//  Created by GeoSpark Mac 15 on 26/03/20.
//  Copyright © 2020 GeoSpark. All rights reserved.
//

import UIKit
import UserNotifications
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    fileprivate var currentBGTask: UIBackgroundTaskIdentifier?
    static let geoCoder = CLGeocoder()
    let center = UNUserNotificationCenter.current()
    let locationManager = CLLocationManager()
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
        }

        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startMonitoringVisits()

        if UserDefaults.standard.bool(forKey: "IsFirst") == false{
            UserDefaults.standard.set(true, forKey: "IsFirst")
            locationManager.startMonitoringSignificantLocationChanges()
        }

//        locationManager.distanceFilter = 35 // 0
//        locationManager.allowsBackgroundLocationUpdates = true // 1
//        locationManager.startUpdatingLocation()  // 2

        self.registerBG()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func registerBG(){
        currentBGTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            if self.currentBGTask != UIBackgroundTaskIdentifier.invalid{
                UIApplication.shared.endBackgroundTask(self.currentBGTask!)
                self.currentBGTask = UIBackgroundTaskIdentifier.invalid
            }
        })
    }
}

extension AppDelegate:CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        let clLocation = CLLocation(latitude: visit.coordinate.latitude, longitude: visit.coordinate.longitude)
        AppDelegate.geoCoder.reverseGeocodeLocation(clLocation) { (placemarks, error) in
            if let place = placemarks?.first{
                let desc = "\(place)"
                self.newVisitReceived(visit, description: desc)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        LoggerManager.sharedInstance.writeLocationToFile(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      guard let location = locations.first else {
        return
      }
      
      AppDelegate.geoCoder.reverseGeocodeLocation(location) { placemarks, _ in
        if let place = placemarks?.first {
          let description = "SignificantLocation \(place)"
          let fakeVisit = FakeVisit(coordinates: location.coordinate, arrivalDate: Date(), departureDate: Date())
          self.newVisitReceived(fakeVisit, description: description)
        }
      }
    }
    
    func newVisitReceived(_ visit: CLVisit, description: String) {
        let location = Location(visit: visit, descriptionString: description)
        LocationsStorage.shared.saveLocationOnDisk(location)
        LoggerManager.sharedInstance.writeLocationToFile(location.description)

        let content = UNMutableNotificationContent()
        content.title = "New Journal entry 📌"
        content.body = location.description
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: location.arravialDateString, content: content, trigger: trigger)
        
        center.add(request, withCompletionHandler: nil)
    }
    
}
final class FakeVisit: CLVisit {
  private let myCoordinates: CLLocationCoordinate2D
  private let myArrivalDate: Date
  private let myDepartureDate: Date

  override var coordinate: CLLocationCoordinate2D {
    return myCoordinates
  }
  
  override var arrivalDate: Date {
    return myArrivalDate
  }
  
  override var departureDate: Date {
    return myDepartureDate
  }
  
  init(coordinates: CLLocationCoordinate2D, arrivalDate: Date, departureDate: Date) {
    myCoordinates = coordinates
    myArrivalDate = arrivalDate
    myDepartureDate = departureDate
    super.init()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
