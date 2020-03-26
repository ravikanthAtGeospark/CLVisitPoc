//
//  LogsViewController.swift
//  CLVisitPoc
//
//  Created by GeoSpark Mac 15 on 26/03/20.
//  Copyright © 2020 GeoSpark. All rights reserved.
//

import UIKit

class LogsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var dataCount:[Dictionary<String,Any>] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "LocationTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "LocationTableViewCell")
        serverLogs()
    }
    
    func serverLogs(){
        let dataArray = UserDefaults.standard.array(forKey: "GeoSparkKeyForLatLongInfo")
        if dataArray?.count != 0 && dataArray != nil{
            dataCount = dataArray as! [Dictionary<String,Any>]
            DispatchQueue.main.async {
                self.dataCount = self.dataCount.reversed()
                self.tableView.reloadData()
            }
        }
    }
    static public func viewController() -> LogsViewController {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let logsDisplayVC = storyBoard.instantiateViewController(withIdentifier: "LogsViewController") as! LogsViewController
        return logsDisplayVC
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)

    }

}

extension LogsViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataCount.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell") as? LocationTableViewCell
        print(dataCount[indexPath.row])
        let dic:Dictionary<String,Any> = dataCount[indexPath.row]
        let lat = dic["latitude"] as? Double
        let lng = dic["longitude"] as? Double
        let source = dic["source"] as? String
        let date = dic["timeStamp"] as? String

        cell?.lat.text = "latitude   " + "\(String(describing: lat!))"
        cell?.lng.text = "longitude   " + "\(String(describing: lng!))"
        cell?.status.text =  source
        cell?.date.text = "Recorded at   " + date!
        return cell!
    }
}
//        let dataDictionary = ["latitude" : location.latitude, "longitude" : location.longitude,"timeStamp" : currentTimestampWithHours(),"source":source] as [String : Any]

