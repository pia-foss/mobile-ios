//
//  AccessibilityIdentifiers.swift
//  PIA VPN
//
//  Created by Waleed Mahmood on 07.03.22.
//

import Foundation

struct Accessibility {
    struct Id {
        struct Welcome {
            static let environment = "id.welcome.environment"
        }
        struct Login {
            static let submit = "id.login.submit"
            static let submitNew = "id.login.submit.new"
            static let username = "id.login.username"
            static let password = "id.login.submit"
            struct Error {
                static let banner = "id.login.error.banner"
            }
        }
        struct Permissions {
            static let submit = "id.permissions.ok.button"
        }
        struct Dashboard {
            static let menu = "id.dashboard.menu"
        }
        struct Menu {
            static let logout = "id.menu.logout"
        }
        struct Dialog {
            static let destructive = "id.dialog.destructive.button"
        }
    }
}
