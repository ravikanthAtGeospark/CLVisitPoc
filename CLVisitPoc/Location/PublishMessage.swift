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
    let activity: String
    let speed:Double
    let bearing: Double
    let battery:Int

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



