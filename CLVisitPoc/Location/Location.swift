//
//  LocationManager.swift
//  CLVisitPoc
//
//  Created by GeoSpark Mac 15 on 27/03/20.
//  Copyright © 2020 GeoSpark. All rights reserved.
//

import Foundation
import CoreLocation

class Location: Codable {
  static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .medium
    return formatter
  }()
  
  var coordinates: CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
  
  let latitude: Double
  let longitude: Double
  let date: Date
  let departureDate: Date
  let arravialDateString: String
  let description: String
  
  init(_ location: CLLocationCoordinate2D, dateArrival: Date, dateDepart: Date,descriptionString: String) {
    latitude =  location.latitude
    longitude =  location.longitude
    self.date = dateArrival
    self.departureDate = dateDepart
    arravialDateString = Location.dateFormatter.string(from: dateArrival)
    description = descriptionString
  }
  
  convenience init(visit: CLVisit, descriptionString: String) {
    self.init(visit.coordinate, dateArrival: visit.arrivalDate,dateDepart:visit.departureDate, descriptionString: descriptionString)
  }
}
