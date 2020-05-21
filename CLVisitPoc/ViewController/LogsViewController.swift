//
//  LogsViewController.swift
//  CLVisitPoc
//
//  Created by GeoSpark Mac 15 on 26/03/20.
//  Copyright © 2020 GeoSpark. All rights reserved.
//

import UIKit
import UserNotifications

class LogsViewController: UITableViewController {
    
    
    var dataCount:[Dictionary<String,Any>] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        serverLogs()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(serverLogs),
            name: .newLocationSaved,
            object: nil)
        
        
    }
    
    @objc func serverLogs(){
        let dataArray = UserDefaults.standard.array(forKey: "GeoSparkKeyMapLocation")
        if dataArray?.count != 0 && dataArray != nil{
            dataCount = dataArray as! [Dictionary<String,Any>]
            DispatchQueue.main.async {
                self.dataCount = self.dataCount.reversed()
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func newLocationAdded(_ notification: Notification) {
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataCount.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath)
        let dic:Dictionary<String,Any> = dataCount[indexPath.row]
        cell.textLabel?.text = dic["desc"] as? String
        cell.detailTextLabel?.text = dic["timeStamp"] as? String
        return cell
    }
    
}

