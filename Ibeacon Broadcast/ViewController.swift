//
//  ViewController.swift
//  Ibeacon Broadcast
//
//  Created by mohamed hashem on 10/13/19.
//  Copyright © 2019 mohamed hashem. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth


struct BeaconStruct {
    var UUID: String?
    var mijor: NSNumber?
    var minor: NSNumber?
    
    init(mijor: NSNumber, minor: NSNumber, uuid: String ) {
        self.UUID = uuid
        self.mijor = mijor
        self.mijor = minor
    }
}

class ViewController: UIViewController {

    var locationManager: CLLocationManager?
    var lastProximity: CLProximity?
    var beaconRegion: CLBeaconRegion?
    
//    var BluetoothManger: CBCentralManager?
//    var peripheral:CBPeripheral!
//    let servicesUUID = CBUUID(nsuuid: UUID(uuidString:"DADFA652-BADC-414E-A236-92EDBDAE3C11")!)
    
    var beaconData: [BeaconStruct] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        useIBeacon()
        //useBluetooth()
       
    }
    
    func useIBeacon() {
        let uuidString = "DADFA652-BADC-414E-A236-92EDBDAE3C11"
               let beaconRegionIdentifier = "Butterfly DADFA652-BADC-414E-A236-92EDBDAE3C11"
               let beaconUUID = UUID(uuidString: uuidString) ?? UUID(uuidString:"DADFA652-BADC-414E-A236-92EDBDAE3C11")
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

//    func useBluetooth() {
//        BluetoothManger = CBCentralManager(delegate: self, queue: nil)
//    }

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
                print("unknown major is: \(CLBeacon.major),minor is: \(CLBeacon.minor), RSSI is: \(CLBeacon.rssi) ")
                
                beaconData.append(BeaconStruct(mijor: CLBeacon.major, minor: CLBeacon.minor, uuid: "DADFA652-BADC-414E-A236-92EDBDAE3C11"))
                tableView.reloadData()
                
                
            case .immediate:
                print("immediate major is: \(CLBeacon.major),minor is: \(CLBeacon.minor), RSSI is: \(CLBeacon.rssi) ")
                
                beaconData.append(BeaconStruct(mijor: CLBeacon.major, minor: CLBeacon.minor, uuid: "DADFA652-BADC-414E-A236-92EDBDAE3C11"))
                
                tableView.reloadData()
                
            case .near:
                print("near major is: \(CLBeacon.major),minor is: \(CLBeacon.minor), RSSI is: \(CLBeacon.rssi) ")
                
                beaconData.append(BeaconStruct(mijor: CLBeacon.major, minor: CLBeacon.minor, uuid: "DADFA652-BADC-414E-A236-92EDBDAE3C11"))
                tableView.reloadData()
                
            case .far:
                print("far major is: \(CLBeacon.major),minor is: \(CLBeacon.minor), RSSI is: \(CLBeacon.rssi) ")
                
                beaconData.append(BeaconStruct(mijor: CLBeacon.major, minor: CLBeacon.minor, uuid: "DADFA652-BADC-414E-A236-92EDBDAE3C11"))
                tableView.reloadData()
                
            @unknown default:
                break
            }
            
        }
        
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


//MARK:- ibeacon with Bluetooth
//extension ViewController: CBCentralManagerDelegate, CBPeripheralDelegate  {
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        if central.state == .poweredOn {
//            print(central.scanForPeripherals(withServices: [servicesUUID] , options: nil))
//
//        } else {
//          print("Bluetooth not available.")
//        }
//    }
//
//    private func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral,
//      advertisementData: [String : AnyObject],
//      RSSI: NSNumber) {
//
//        BluetoothManger?.stopScan()
//        self.peripheral = peripheral
//        BluetoothManger?.connect(peripheral, options: nil)
//
//    }
//
//    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        peripheral.delegate = self
//        peripheral.discoverServices([servicesUUID])
//    }
//
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        if let service = peripheral.services?.first(where: { $0.uuid == servicesUUID }) {
//            print("ok ",service)
//        }
//    }
//
//    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        if let data = characteristic.value {
//            print("data is ", data.withUnsafeBytes({ $0.endIndex}))
//        }
//    }
//}

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
                   
        }
       
        return cell
    }
}
