//
//  ViewController.swift
//  Ibeacon Broadcast
//
//  Created by mohamed hashem on 10/13/19.
//  Copyright © 2019 mohamed hashem. All rights reserved.
//

import UIKit
import CoreLocation
import RxSwift

struct BeaconStruct {
    var UUID: String?
    var mijor: NSNumber?
    var minor: NSNumber?
    var rssi: Int?
    
    init(mijor: NSNumber, minor: NSNumber, uuid: String, rssi: Int ) {
        self.UUID = uuid
        self.mijor = mijor
        self.mijor = minor
        self.rssi = rssi
    }
}

class ViewController: UIViewController {
    
    var locationManager: CLLocationManager?
    var lastProximity: CLProximity?
    var beaconRegion: CLBeaconRegion?
    var beaconData: [BeaconStruct] = []
    //let uuidString = "DADFA652-BADA-414E-A236-92EDBDAE3C11"
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataShared().ibeaconUUID = "DADFA652-BADA-414E-A236-92EDBDAE3C11"
        useIBeacon()
    }
    
}

//MARK:- ibeacon with Beacon
extension ViewController: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        manager.startRangingBeacons(in: region as! CLBeaconRegion)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        manager.startRangingBeacons(in: region as! CLBeaconRegion)
        manager.startUpdatingLocation()
        print("you enter ragion")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        manager.stopRangingBeacons(in: region as! CLBeaconRegion)
        manager.stopUpdatingLocation()
        print("you exit ragion")
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        print("number of beacon founded is: ", beacons.count)
        
        if beacons.last?.rssi != nil {
            print("distance 1 is: ", calculateNewDistance(txCalibratedPower: -59, rssi: beacons.last!.rssi))
            
            let distanc3 = pow(10.0, (-69 - Double(beacons.last!.rssi)) / (10 * 2))
            print("distance 3 is: ",distanc3)
        }
        
        beacons.forEach { (CLBeacon) in
            switch CLBeacon.proximity {
            case .unknown:
                beaconData.append(BeaconStruct(mijor: CLBeacon.major, minor: CLBeacon.minor, uuid: DataShared().ibeaconUUID!, rssi: CLBeacon.rssi))
                tableView.reloadData()
                
                
                
            case .immediate:
                beaconData.append(BeaconStruct(mijor: CLBeacon.major, minor: CLBeacon.minor, uuid: DataShared().ibeaconUUID!, rssi: CLBeacon.rssi))
                
                tableView.reloadData()
                
            case .near:
                beaconData.append(BeaconStruct(mijor: CLBeacon.major, minor: CLBeacon.minor, uuid: DataShared().ibeaconUUID!, rssi: CLBeacon.rssi))
                tableView.reloadData()
                
            case .far:
                beaconData.append(BeaconStruct(mijor: CLBeacon.major, minor: CLBeacon.minor, uuid: DataShared().ibeaconUUID!, rssi: CLBeacon.rssi))
                tableView.reloadData()
                
            @unknown default:
                break
            }
            
        }
        
    }
    
    
    private func useIBeacon() {
        let beaconRegionIdentifier = "Butterfly DADFA652-BADA-414E-A236-92EDBDAE3C11"
        let beaconUUID = UUID(uuidString: DataShared().ibeaconUUID!) ?? UUID(uuidString:"DADFA652-BADA-414E-A236-92EDBDAE3C11")
        
        beaconRegion = CLBeaconRegion(proximityUUID: beaconUUID!, identifier: beaconRegionIdentifier)
        
        beaconRegion?.notifyOnEntry = true
        beaconRegion?.notifyOnExit = true
        beaconRegion?.notifyEntryStateOnDisplay = true
        
        locationManager = CLLocationManager()
        locationManager?.requestAlwaysAuthorization()
        locationManager?.delegate = self
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager?.startRangingBeacons(in: beaconRegion! )
        locationManager?.startMonitoring(for: beaconRegion!)
        
        locationManager?.startUpdatingLocation()
    }
    
    func calculateNewDistance(txCalibratedPower: Int, rssi: Int) -> Double {
        //txCalibratedPower = -59
        if rssi == 0 { return -1 }
        let ratio = Double(exactly:rssi)!/Double(txCalibratedPower)
        if ratio < 1.0 {
            return pow(10.0, ratio)
        } else {
            let accuracy = 0.89976 * pow(ratio, 7.7095) + 0.111
            return accuracy
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beaconData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CellBeacon
        if !beaconData.isEmpty {
            cell.uuidLabel.text = beaconData[indexPath.row ].UUID
            cell.mijorLabel.text = beaconData[indexPath.row ].mijor?.stringValue
            cell.minorLabel.text = beaconData[indexPath.row ].minor?.stringValue
            if beaconData[indexPath.row ].rssi != nil {
               cell.rssiLabel.text = String(beaconData[indexPath.row ].rssi!)
            }
        }
        
        return cell
    }
}
