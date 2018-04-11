//
//  Macros+Notifications.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/15/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import PIALibrary
import SwiftyBeaver

private let log = SwiftyBeaver.self

extension Macros {
    static func postAppNotification(_ name: Notification.Name, _ userInfo: [NotificationKey: Any]? = nil, _ logging: Bool = true) {
        if logging {
            if let userInfo = userInfo {
                log.debug("Notifications: Posting \(name) (userInfo: \(userInfo))")
            } else {
                log.debug("Notifications: Posting \(name)")
            }
        }
        NotificationCenter.default.post(name: name, object: nil, userInfo: userInfo)
    }
}
