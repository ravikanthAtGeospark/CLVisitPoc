//
//  Utilis.swift
//  CLVisitPoc
//
//  Created by GeoSpark Mac 15 on 29/04/20.
//  Copyright © 2020 GeoSpark. All rights reserved.
//

import Foundation
import CoreLocation

class Utilis: NSObject {
    
    static func savePDFData(_ desc:String?){
        let des = "\(currentTimestamp()) \("        ")\(desc!)"
        let dataDictionary = ["description":des] as [String : Any]
        var dataArray = UserDefaults.standard.array(forKey: "GeneratePDF")
        if let _ = dataArray {
            dataArray?.append(dataDictionary)
        }else{
            dataArray = [dataDictionary]
        }
        UserDefaults.standard.set(dataArray, forKey: "GeneratePDF")
        UserDefaults.standard.synchronize()
    }
    
    
    static func saveLogsMap(_ location:CLLocation,_ descr:String){
        
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

    
    static func saveLocationToLocal(_ location:CLLocation,activity:String) {
        print("saveLocationToLocal",activity)
        let dataDictionary = ["latitude" : location.coordinate.latitude, "longitude" : location.coordinate.longitude,"desc":"Precise location \("    ") \(location.description)","timeStamp" : currentTimestamp(),"activity":activity] as [String : Any]
        var dataArray = UserDefaults.standard.array(forKey: "GeoSparkKeyForLatLongInfo")
        if let _ = dataArray {
            dataArray?.append(dataDictionary)
        }else{
            dataArray = [dataDictionary]
        }
        UserDefaults.standard.set(dataArray, forKey: "GeoSparkKeyForLatLongInfo")
        UserDefaults.standard.synchronize()
    }

    
    static func currentTimestamp() -> String {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MMM-dd HH:mm:ss"
        let date = Date()
        return dateFormatter.string(from: date)
    }

}
