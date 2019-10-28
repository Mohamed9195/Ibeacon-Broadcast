//
//  LocationServiceManager.swift
//  Butterfly
//
//  Created by Ahmed Henawey on 8/18/19.
//  Copyright © 2019 Xtrava Inc. All rights reserved.
//

import CoreLocation
import RxSwift
import RxCocoa

class LocationServiceManager {
    let stateSubject = ReplaySubject<ServiceStatus>.create(bufferSize: 1)
    fileprivate let locationManager = CLLocationManager()
    fileprivate let disposeBag = DisposeBag()
    
    init() {
        locationManager
            .rx
            .didChangeAuthorization
            .bind(to: stateSubject)
            .disposed(by: disposeBag)
        
        checkStatus()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(checkStatus), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    deinit {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self)
    }
    
    @objc fileprivate func checkStatus() {
        guard CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self),
            CLLocationManager.locationServicesEnabled() else {
                stateSubject.onNext(ServiceStatus.notAuthorized)
                return
        }
        
        stateSubject.onNext(CLLocationManager.authorizationStatus().serviceStatus)
    }
}

extension CLLocationManager: HasDelegate {
    public typealias Delegate = CLLocationManagerDelegate
}

fileprivate class RxCLLocationManagerDelegateProxy:
    DelegateProxy<CLLocationManager, CLLocationManagerDelegate>,
    CLLocationManagerDelegate,
    DelegateProxyType {
    
    public weak private(set) var locationManager: CLLocationManager?
    
    public init(locationManager: ParentObject) {
        self.locationManager = locationManager
        super.init(parentObject: locationManager, delegateProxy: RxCLLocationManagerDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        register { RxCLLocationManagerDelegateProxy(locationManager: $0) }
    }
}

fileprivate extension Reactive where Base: CLLocationManager {
    typealias DidChangeAuthorization = (ServiceStatus)
    
    var delegate: DelegateProxy<CLLocationManager, CLLocationManagerDelegate> {
        return RxCLLocationManagerDelegateProxy.proxy(for: base)
    }
    
    var didChangeAuthorization: ControlEvent<DidChangeAuthorization> {
        let source: Observable<DidChangeAuthorization> = delegate
            .methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didChangeAuthorization:)))
            .map { arg in
                guard let rawStatus = arg[1] as? Int32,
                    let status = CLAuthorizationStatus(rawValue: rawStatus) else {
                    throw RxCocoaError.castingError(object: arg[1], targetType: CLAuthorizationStatus.self)
                }
                return status.serviceStatus
        }
        return ControlEvent(events: source)
    }
}

fileprivate extension CLAuthorizationStatus {
    var serviceStatus: ServiceStatus {
        switch self {
        case .notDetermined:
            return ServiceStatus.unknown
            
        case .denied:
            return ServiceStatus.notAuthorized
            
        case .authorizedAlways, .authorizedWhenInUse, .restricted:
            return ServiceStatus.enabled
            
        @unknown default:
            return ServiceStatus.unknown
        }
    }
}
