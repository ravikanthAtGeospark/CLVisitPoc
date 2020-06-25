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
class AppDelegate: UIResponder, UIApplicationDelegate,LocationManagerDelegate{
    
    
    fileprivate var currentBGTask: UIBackgroundTaskIdentifier?
    static let geoCoder = CLGeocoder()
    let center = UNUserNotificationCenter.current()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        LocationManager.sharedInstance.startTracking()
        LocationManager.sharedInstance.delegate = self
        
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
        }
        
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
    
    
    func updateLocation(_ location: CLLocation, desc: String, activity: String) {
        self.updateData(location, desc: desc + "        " +  location.description, activity: activity)
        Utilis.saveLocationToLocal(location, activity: activity)
        print(location)
        print("Activity    \(activity) \("      Type \(desc)")")
    }
    
    func updateData(_ location: CLLocation, desc: String, activity: String) {
        let content = UNMutableNotificationContent()
        content.title = "Location Update \(desc)"
        content.body = location.description
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "\(location.timestamp)", content: content, trigger: trigger)
        center.add(request, withCompletionHandler: nil)
        
    }
    
    func batteryStatus() -> Int{
        return Int(UIDevice.current.batteryLevel*100)
    }
    
    func getUUID() -> String{
        return (UIDevice.current.identifierForVendor?.uuidString)!
    }
    
    
    
}

extension TimeInterval {
    private var milliseconds: Int {
        return Int((truncatingRemainder(dividingBy: 1)) * 1000)
    }
    
    var minutes: Int {
        return (Int(self) / 60 ) % 60
    }
    
}

extension CLLocation{
    
    func getAddress(){
        CLGeocoder().reverseGeocodeLocation(self) { (placmark, error) in
            
        }
    }
}
