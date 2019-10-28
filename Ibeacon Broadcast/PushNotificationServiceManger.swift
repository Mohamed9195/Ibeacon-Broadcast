//
//  PushNotificationServiceManger.swift
//  Butterfly
//
//  Created by mohamed hashem on 8/19/19.
//  Copyright © 2019 Xtrava Inc. All rights reserved.
//

import UserNotifications
import RxSwift
import RxCocoa

 class UserNotificationServiceManager {
    let stateSubject = ReplaySubject<ServiceStatus>.create(bufferSize: 1)
    
    init() {
        checkStatus()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(checkStatus), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    deinit {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self)
    }
    
    @objc fileprivate func checkStatus() {
        UNUserNotificationCenter.current()
            .getNotificationSettings { [weak self] (settings) in
                guard let self = self else { return }
                
                switch settings.authorizationStatus {
                case .notDetermined:
                    self.stateSubject.onNext(.notAuthorized)
                    
                case .denied:
                    self.stateSubject.onNext(.disabled)
                    
                case .authorized, .provisional:
                    self.stateSubject.onNext(.enabled)
        
                @unknown default:
                    self.stateSubject.onNext(.unknown)
                }
        }
    }
}
