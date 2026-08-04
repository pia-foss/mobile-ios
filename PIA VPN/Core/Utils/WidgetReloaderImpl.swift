//
//  WidgetReloaderImpl.swift
//  PIA VPN
//
//  Created by Mario on 05/08/26.
//  Copyright © 2026 Private Internet Access, Inc. All rights reserved.
//

import PIALibrary
import WidgetKit

struct WidgetReloaderImpl: WidgetsReloader {
    func reloadWidgets() {
        WidgetCenter.shared.reloadTimelines(ofKind: AppConstants.Widget.kind)
        #if !targetEnvironment(macCatalyst)
            if #available(iOS 16.2, *) {
                PIAConnectionLiveActivityManager.shared.refreshLiveActivities()
            }
        #endif
    }
}
