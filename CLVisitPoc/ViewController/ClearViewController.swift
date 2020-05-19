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
    
    
    @IBAction func updateCurrentBtn(_ sender: Any) {
        LocationManager.sharedInstance.updateCurrentLocation()
    }
    
    @IBAction func clearBtn(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "GeoSparkKeyForLatLongInfo")
        UserDefaults.standard.removeObject(forKey: "GeoSparkKeyMapLocation")
        UserDefaults.standard.removeObject(forKey: "GeneratePDF")
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: .newLocationSaved, object: self)
    }
    
    
    @IBAction func exportBtn(_ sender: Any) {
        
        let dataArray = UserDefaults.standard.array(forKey: "GeneratePDF") as? [Dictionary<String,Any>]
        var dataString = ""
        
        for data in (dataArray?.enumerated())! {
            print(data.element)
            let dataValue = data.element
            let desc = dataValue["description"] as? String
            if dataString == "" {
                dataString = desc! + "\n"
            }else{
                dataString = dataString + desc! + "\n"
            }
        }
        

        let deviceName = UIDevice().type.rawValue  + "    " + getUUID()
        let pdfCreator = PDFCreator(title: deviceName , body: dataString)
        let pdfData = pdfCreator.createFlyer()
        let vc = UIActivityViewController(activityItems: [pdfData], applicationActivities: [])
        present(vc, animated: true, completion: nil)
       
    }
    
     func getUUID() -> String{
        return (UIDevice.current.identifierForVendor?.uuidString)!
    }



}
extension Notification.Name {
    static let newLocationSaved = Notification.Name("newLocationSaved")
}

