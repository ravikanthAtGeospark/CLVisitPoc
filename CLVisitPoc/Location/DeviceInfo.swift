//
//  DeviceInfo.swift
//  CLVisitPoc
//
//  Created by GeoSpark Mac 15 on 15/05/20.
//  Copyright © 2020 GeoSpark. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CoreTelephony


class DeviceInfo: NSObject {
    
    static func batteryStatus() -> Int{
        return Int(UIDevice.current.batteryLevel*100)
    }
    
    static func getUUID() -> String{
        return (UIDevice.current.identifierForVendor?.uuidString)!
    }
    
    
    static func batteryState() -> String{
        let state = UIDevice.current.batteryState
        if state == .charging {
            return "Charging"
        }else if  state == .full {
            return "Full"
        } else  if state == .unplugged{
            return "Unplugged"
        } else{
            return "Unknown"
        }
    }
    
    static func deviceModel() ->String{
        return UIDevice().type.rawValue
        //        return UIDevice.modelName.replacingOccurrences(of: " ", with: "%20")
    }
    
    static func deviceBrand() ->String{
        return UIDevice.current.model
        
    }
    
    static func osVersion() ->String{
        return UIDevice.current.systemVersion
    }
    
    static func locationStatus() -> Bool{
        if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse{
            return true
        }else{
            return false
        }
    }
    
    static func carrierName() -> String{
        let networkInfo = CTTelephonyNetworkInfo()
        let dataServiceIdentifier = networkInfo.dataServiceIdentifier
        let currentProvider  = networkInfo.serviceSubscriberCellularProviders![dataServiceIdentifier!]
        return (currentProvider?.carrierName)!
    }
    
    
}
