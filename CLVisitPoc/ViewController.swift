//
//  ViewController.swift
//  CLVisitPoc
//
//  Created by GeoSpark Mac 15 on 26/03/20.
//  Copyright © 2020 GeoSpark. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {


    @IBOutlet weak var visitCount: UILabel!
    @IBOutlet weak var lastVisitDetail: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataArray = UserDefaults.standard.array(forKey: "GeoSparkKeyForLatLongInfo")
        if dataArray?.count != 0{
            visitCount.text = "\(dataArray?.count ?? 0)"
        }
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: .updateVisit, object: self)
    }
    
    @objc func updateUI(notification: Notification){
        guard let yourPassedObject = notification.object as? [String:Any] else {
            return
        }

        if let detail = yourPassedObject["visit"] as? CLVisit{
            DispatchQueue.main.async{
                self.lastVisitDetail.text = detail.description
            }
        }
    }


}


extension Notification.Name {
    static let updateVisit = Notification.Name("updateVisit")
}

