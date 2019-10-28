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
import RxSwift
import RxBluetoothKit


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
    
    
    var manager: CentralManager?
    
    //    var peripheral:CBPeripheral!
    //    let servicesUUID = CBUUID(nsuuid: UUID(uuidString:"DADFA652-BADC-414E-A236-92EDBDAE3C11")!)
    
    var beaconData: [BeaconStruct] = []
    fileprivate let serviceStatusManager: ServiceStatusManager = ServiceStatusManager()
    fileprivate let disposeBag: DisposeBag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let options = [CBCentralManagerOptionRestoreIdentifierKey: "RestoreIdentifierKey"] as [String: AnyObject]
        manager = CentralManager(queue: .main, options: nil)
        
        serviceStatusManager
            .observe(services: .bluetooth)
            .debug("serviceStatusManager")
            .subscribe(onNext: { (output) in
                switch output.service {
                case .location: break
                case .notification: break
                case .bluetooth:
                    if output.status == .enabled {
                        self.useBluetooth()
                    }
                }
            }).disposed(by: disposeBag)
        
        useIBeacon()
        
        
    }
    
    func useBluetooth() {
        
        //       manager.observeState()
        //        .startWith(state)
        //        .filter { $0 == .poweredOn }
        //        .flatMap { manager.scanForPeripherals(withService: [serviceId]) }
        //        .take(1)
        //        .flatMap { $0.peripheral.establishConnection() }
        //        .subscribe(onNext: { peripheral in
        //             print("Connected to: \(peripheral)")
        //        })
  
        
    /// scan for butterfly
        manager?.observeState()
            .startWith(manager!.state)
            .filter{ $0 == .poweredOn }
            .timeout(5.0, scheduler: MainScheduler.instance)
            .flatMap{ _ in
                self.manager!.scanForPeripherals(withServices: nil)
        }
        .subscribe(onNext: { (peripheral) in
            let scannedPeripheral: ScannedPeripheral = peripheral
          //  self.openConnectionOnly(device: scannedPeripheral)
            self.openConnectionWithAllServices(device: scannedPeripheral)
        }, onError: { (error) in
            print("error is:", error)
        }).disposed(by: disposeBag)
        
    }
    
    /// open connection with  butterfly
//    func openConnectionOnly(device: ScannedPeripheral) {
//        device.peripheral.establishConnection()
//            .subscribe(onNext: {
//                print("Connected to: \($0.canSendWriteWithoutResponse)")
//            }).disposed(by: disposeBag)
//    }
    
    func openConnectionWithAllServices(device: ScannedPeripheral) {
        device.peripheral.establishConnection()
            .flatMap { $0.discoverServices(
//                [CBUUID(string: "180A"),
//            CBUUID(string: "180F"),
//            CBUUID(string: "FE59"),
//            CBUUID(string: "BBC20001-8470-436A-882D-F6F90AFD73DB"),
//            CBUUID(string: "CCC20001-8470-436A-882D-F6F90AFD73DB"),
//            CBUUID(string: "DDC20001-8470-436A-882D-F6F90AFD73DB")]
              [ CBUUID(string: "CCC20001-8470-436A-882D-F6F90AFD73DB")]
                )}
            .asObservable()
            .flatMap { Observable.from($0) }
            .flatMap { $0.discoverCharacteristics([CBUUID(string: "CCC22004-8470-436A-882D-F6F90AFD73DB")])}
            .asObservable()
            .flatMap { Observable.from($0) }
            .subscribe(onNext: { characteristic in
                print("Discovered characteristic: \(characteristic.uuid)")
                let proximityUUIDData = UUID(uuidString:"DADFA652-BADA-414E-A236-92EDBDAE3C11")?.uuidString.replacingOccurrences(of: "-", with: "").hexadecimal()
                characteristic.writeValue(proximityUUIDData!, type: .withResponse)
                .subscribe { event in
                    //respond to errors / successful read
                }.disposed(by: self.disposeBag)
            }).disposed(by: disposeBag)
    }
    
//    internal func setProximityUUID(device: Device, proximityUUID: UUID) -> Observable<Device> {
//          // Workaroud: this happen because the fireware guys have a problem to handle the normal uuid generated from iOS. so just remove "-" then convert it to hexadecimal string
//          let proximityUUIDData = proximityUUID.uuidString.replacingOccurrences(of: "-", with: "").hexadecimal()
//
//          let stateObservable = manager.observePoweredOnState()
//
//          struct StreamerConigurationServiceIdentifier: ServiceIdentifier {
//              var uuid: CBUUID {
//                  return CBUUID(string: "CCC20001-8470-436A-882D-F6F90AFD73DB")
//              }
//          }
//
//          struct WriteProximityUUIDCharacteristicIdentifier: CharacteristicIdentifier {
//              static let shared = WriteProximityUUIDCharacteristicIdentifier()
//
//              var uuid: CBUUID {
//                  return CBUUID(string: "CCC22004-8470-436A-882D-F6F90AFD73DB")
//              }
//
//              var service: ServiceIdentifier {
//                  return StreamerConigurationServiceIdentifier()
//              }
//          }
//
//          let writeObservable =
//              device.characteristic(with: WriteProximityUUIDCharacteristicIdentifier.shared).asObservable()
//                  // write
//                  .flatMap { $0.writeValue(proximityUUIDData!, type: .withResponse) }
//
//
//          return stateObservable
//              .flatMap { _ in return writeObservable }
//              .map { _ in return device }
//      }
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
    
    
    func useIBeacon() {
        let uuidString = "DADFA652-BADA-414E-A236-92EDBDAE3C11"
        let beaconRegionIdentifier = "Butterfly DADFA652-BADA-414E-A236-92EDBDAE3C11"
        let beaconUUID = UUID(uuidString: uuidString) ?? UUID(uuidString:"DADFA652-BADA-414E-A236-92EDBDAE3C11")
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


//MARK:- ibeacon with Bluetooth
//extension ViewController: CBCentralManagerDelegate, CBPeripheralDelegate  {
//
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


extension String {
    func hexadecimal() -> Data? {
           var data = Data(capacity: count / 2)
           
           let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
           regex.enumerateMatches(in: self, options: [], range: NSMakeRange(0, count)) { match, flags, stop in
               let byteString = (self as NSString).substring(with: match!.range)
               var num = UInt8(byteString, radix: 16)!
               data.append(&num, count: 1)
           }
           
           guard data.count > 0 else {
               return nil
           }
           
           return data
       }
}
