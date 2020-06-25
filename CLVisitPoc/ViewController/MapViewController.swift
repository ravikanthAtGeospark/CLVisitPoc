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
    
    var locations: [[String: Any]]?
    let annotation = MKPointAnnotation()
    var points: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
    var last:CLLocationCoordinate2D?
    var datePicker : UIDatePicker!
    let toolBar = UIToolbar()
    
    static public func viewController() -> MapViewController {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let logsDisplayVC = storyBoard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        return logsDisplayVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        setAnnotations()
        NotificationCenter.default.addObserver(self, selector: #selector(setAnnotations), name: .newLocationSaved, object: nil)
    }
    
    
    @objc func setAnnotations(){
        
        clearMonitoring()
        
        let datas  = UserDefaults.standard.array(forKey: "GeoSparkKeyForLatLongInfo") as? [[String:Any]]
        if  datas != nil{
            var dataValue:[[String:Any]] = []
            for data in (datas?.enumerated())! {
                let dateVal = data.element
                dataValue.append(dateVal)
            }
                        
            let annotations = getMapAnnotations(dataValue)
            mapView.addAnnotations(annotations)
            for annotation in annotations {
                points.append(annotation.coordinate)
                if (annotations.last != nil){
                    last = CLLocationCoordinate2D(latitude: (annotations.last?.latitude)!, longitude: (annotations.last?.longitude)!)
                    zoomToRegion(last!)
                }
            }
            
            if points.count != 0 {
                let polyline = MKPolyline(coordinates: &points, count: points.count)
                mapView.addOverlay(polyline)
                points.removeAll()
            }else {
                clearMonitoring()
            }
            
        }
    }
    
    func zoomToRegion(_ location:CLLocationCoordinate2D) {
        
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 5000.0, longitudinalMeters: 7000.0)
        mapView.setRegion(region, animated: false)
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        
        if overlay is MKPolyline {
            polylineRenderer.strokeColor = UIColor.blue
            polylineRenderer.lineWidth = 1
        }
        return polylineRenderer
    }
    
    //MARK:- Annotations
    
    func getMapAnnotations(_ dict:[[String:Any]]) -> [Station] {
        var annotations:Array = [Station]()
        
        for item in dict.enumerated() {
            let locDict = item.element
            let lat = locDict["latitude"] as! Double
            let long = locDict["longitude"] as! Double
            let annotation = Station(latitude: lat, longitude: long)
            annotation.title = locDict["desc"] as? String
            let activity = locDict["activity"] as? String
            annotation.subtitle = activity!
            annotations.append(annotation)
        }
        return annotations
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation { return nil }   // let the OS show user locations itself
        
        let identifier = "pinAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        if annotation.subtitle == "R"{
            annotationView!.pinTintColor = UIColor.blue
        }else if annotation.subtitle == "W"{
            annotationView!.pinTintColor = UIColor.green
        }else{
            annotationView!.pinTintColor = UIColor.red
        }
        annotationView!.displayPriority = .required
        annotationView!.canShowCallout = true
        
        return annotationView
    }
    
    func clearMonitoring(){
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations( annotationsToRemove )
        DispatchQueue.main.async {
            let overlays = self.mapView.overlays.filter{ $0 !== self.mapView.userLocation }
            self.mapView.removeOverlays(overlays)
        }
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
