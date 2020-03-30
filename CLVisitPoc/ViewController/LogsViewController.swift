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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("LogsViewController",LocationsStorage.shared.locations)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(newLocationAdded(_:)),
            name: .newLocationSaved,
            object: nil)
    }
    
    @objc func newLocationAdded(_ notification: Notification) {
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LocationsStorage.shared.locations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath)
        let location = LocationsStorage.shared.locations[indexPath.row]
        cell.textLabel?.text = location.description
        cell.detailTextLabel?.text = location.arravialDateString
        return cell
    }
    
}
