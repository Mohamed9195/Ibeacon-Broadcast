//
//  PermissionMangerManual.swift
//  Butterfly
//
//  Created by mohamed hashem on 7/21/19.
//  Copyright © 2019 Xtrava Inc. All rights reserved.
//


import RxSwift
import RxCocoa

enum Service {
    case bluetooth
    case notification
    case location
}

enum ServiceStatus {
    case enabled
    case disabled
    case notAuthorized
    case unknown
}

class ServiceStatusManager {
    
    private let userNotificationServiceManager = UserNotificationServiceManager()
    private let locationServiceManager = LocationServiceManager()
    private let bluetoothServiceManager = BluetoothServiceManager()
    
    func observe(services: Service...) -> Observable<(service: Service, status: ServiceStatus)> {
        
        var observables = [Observable<(service: Service, status: ServiceStatus)>]()
        
        services.forEach { (service) in
            switch service {
            case .bluetooth:
                let observable = bluetoothServiceManager
                    .stateSubject
                    .asObservable()
                    .distinctUntilChanged()
                observables.append(observable.map { (service: .bluetooth, status: $0) })
            case .notification:
                let observable = userNotificationServiceManager
                    .stateSubject
                    .asObservable()
                    .distinctUntilChanged()
                observables.append(observable.map { (service: .notification, status: $0) })
            case .location:
                let observable = locationServiceManager
                    .stateSubject
                    .asObservable()
                    .distinctUntilChanged()
                observables.append(observable.map { (service: .location, status: $0) })
            }
        }
        return Observable.merge(observables)
    }
}
