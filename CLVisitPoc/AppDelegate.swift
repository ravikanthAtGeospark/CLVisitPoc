//
//  AppDelegate.swift
//  CLVisitPoc
//
//  Created by GeoSpark Mac 15 on 26/03/20.
//  Copyright © 2020 GeoSpark. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {


    let locationManager = CLLocationManager()
    let notificationCenter = UNUserNotificationCenter.current()
    fileprivate var currentBGTask: UIBackgroundTaskIdentifier?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.registerBG()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
        startMonitoringVisits()
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

    func startMonitoringVisits() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startMonitoringVisits()
    }
    
    func stopMonitoringVisits() {
        locationManager.stopMonitoringVisits()
    }

    func showNotification(body: String,_ title: String) {
        let content = UNMutableNotificationContent()

        //adding title, subtitle, body and badge
        content.title = title
        content.body = body
        content.badge = 1

        //getting the notification trigger
        //it will be called after 5 seconds
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        //getting the notification request
        let request = UNNotificationRequest(identifier: "SimplifiedIOSNotification", content: content, trigger: trigger)

        //adding the notification to notification center
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func saveVisits(visit: CLVisit){
        let dataDictionary = ["visit":visit]
        var dataArray = UserDefaults.standard.array(forKey: "GeoSparkKeyForLatLongInfo")
        if let _ = dataArray {
            dataArray?.append(dataDictionary)
        }else{
            dataArray = [dataDictionary]
        }
        UserDefaults.standard.set(dataArray, forKey: "GeoSparkKeyForLatLongInfo")
        UserDefaults.standard.synchronize()
    }
    
    func registerBG(){
        if self.currentBGTask != UIBackgroundTaskIdentifier.invalid{
            UIApplication.shared.endBackgroundTask(self.currentBGTask!)
            self.currentBGTask = UIBackgroundTaskIdentifier.invalid
        }

    }
}
extension AppDelegate:CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        showNotification(body: error.localizedDescription, "Error")
    }
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        print(visit.coordinate)
        showNotification(body: "\(visit.coordinate)", "didVisit")
        NotificationCenter.default.post(name: .updateVisit, object: ["visit":visit])
        LoggerManager.sharedInstance.writeLocationToFile("\("latitude  \(visit.coordinate.latitude)") \("   Longitude \(visit.coordinate.longitude)") \(visit.description)")
    }
    
    
}
