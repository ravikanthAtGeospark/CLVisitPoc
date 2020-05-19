//
//  PublishMessage.swift
//  CocoaMQTTExample
//
//  Created by GeoSpark Mac 15 on 12/12/19.
//  Copyright © 2019 GeoSpark Mac. All rights reserved.
//

import Foundation

struct PublishMessage:Codable {

    let lat : Double
    let lng : Double
    let horizontalaccuracy:Double
    let verticalaccuracy:Double
    let speed:Double
    let battery:Int
    let altitude: Double
    let deviceId:String
    let carrier_name:String
    let course:String
    let device_model:String
    let os_version:String
    let location_permission:Bool
    let timeStamp:String
    let batteryStatus:String
}

extension PublishMessage{
    
    func jsonString() throws -> String{
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(self)
            let jsonString = String(data: jsonData, encoding: .utf8)
            return jsonString!
        }
        catch {
        }
        return ""
    }
    
}


//
//"ad_id":"12a451dd-3539-4092-b134-8cb0ef62ab8a",
//"ad_opt_out":true,
//"id_type":"idfa",
