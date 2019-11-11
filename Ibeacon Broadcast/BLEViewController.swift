//
//  BLEViewController.swift
//  Ibeacon Broadcast
//
//  Created by mohamed hashem on 11/11/19.
//  Copyright © 2019 mohamed hashem. All rights reserved.
//

import UIKit
import CoreBluetooth
import RxSwift
import RxBluetoothKit

class BLEViewController: UIViewController {
    
    var manager: CentralManager?
    
    var peripheral:CBPeripheral!
    let servicesUUID = CBUUID(nsuuid: UUID(uuidString:"DADFA652-BADC-414E-A236-92EDBDAE3C11")!)
    
    fileprivate let serviceStatusManager: ServiceStatusManager = ServiceStatusManager()
    fileprivate let disposeBag: DisposeBag = DisposeBag()
    
    @IBOutlet weak var newUUID: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        _ = [CBCentralManagerOptionRestoreIdentifierKey: "RestoreIdentifierKey"] as [String: AnyObject]
        manager = CentralManager(queue: .main, options: nil)
        
        //checkBluetoothStatus()
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
            self.openConnectionWithAllServices(device: scannedPeripheral, newUUID: self.newUUID.text! )
        }, onError: { (error) in
            print("error is:", error)
        }).disposed(by: disposeBag)
        
    }
    
     
        /// open connection with  butterfly
    func openConnectionOnly(device: ScannedPeripheral) {
        device.peripheral.establishConnection()
            .subscribe(onNext: {
                print("Connected to: \($0.canSendWriteWithoutResponse)")
            }).disposed(by: disposeBag)
    }
    
    func openConnectionWithAllServices(device: ScannedPeripheral, newUUID: String = "DADFA652-BADA-414E-A236-92EDBDAE3C11") {
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
                let proximityUUIDData = UUID(uuidString: newUUID)?.uuidString.replacingOccurrences(of: "-", with: "").hexadecimal()
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
    
    private func checkBluetoothStatus() {
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
    }
    
    @IBAction func pressToRunSetupButterfly(_ sender: UIButton) {
       checkBluetoothStatus()
        DataShared().ibeaconUUID = newUUID.text
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
