//
//  MapViewController.swift
//  CLVisitPoc
//
//  Created by GeoSpark Mac 15 on 30/03/20.
//  Copyright © 2020 GeoSpark. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate{

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(newLocationAdded(_:)),
            name: .newLocationSaved,
            object: nil)

        mapView.delegate = self
        updateMap()
        
    }
    
    func updateMap(){
        clearMonitoring()
        let annotations = getMapAnnotations()
        mapView.addAnnotations(annotations)
  
        guard let firstLocation = LocationsStorage.shared.locations.first else {
            return;
        }
        self.zoomToRegion(CLLocationCoordinate2D(latitude: firstLocation.latitude, longitude: firstLocation.longitude))
    }
    
    
    @objc func newLocationAdded(_ notification: Notification) {
        updateMap()
    }

    
    func getMapAnnotations() -> [Station] {
           var annotations:Array = [Station]()
           
        for item in LocationsStorage.shared.locations.enumerated() {
            let locDict = item.element
            let annotation = Station(latitude: locDict.latitude, longitude: locDict.longitude)
            annotation.title = locDict.description
            annotation.subtitle = locDict.arravialDateString
            annotations.append(annotation)
           }
           return annotations
       }

    func clearMonitoring(){
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations( annotationsToRemove )
        DispatchQueue.main.async {
            let overlays = self.mapView.overlays.filter{ $0 !== self.mapView.userLocation }
            self.mapView.removeOverlays(overlays)
        }
    }

    func zoomToRegion(_ location:CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 5000.0, longitudinalMeters: 7000.0)
        mapView.setRegion(region, animated: true)
    }

}

class Station: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var latitude: Double
    var longitude:Double
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

