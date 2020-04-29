//
//  ClearViewController.swift
//  CLVisitPoc
//
//  Created by GeoSpark Mac 15 on 27/04/20.
//  Copyright © 2020 GeoSpark. All rights reserved.
//

import UIKit

class ClearViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func clearBtn(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "GeoSparkKeyForLatLongInfo")
        UserDefaults.standard.removeObject(forKey: "GeoSparkKeyMapLocation")
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: .newLocationSaved, object: self)
    }

}
extension Notification.Name {
  static let newLocationSaved = Notification.Name("newLocationSaved")
}

