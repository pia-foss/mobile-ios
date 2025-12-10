//
//  AccessibilityIdentifiers.swift
//  PIALibrary
//
//  Created by Waleed Mahmood on 07.03.22.
//

import Foundation

public struct Accessibility {
    public struct Id {
        public struct Welcome {
            public static let environment = "id.welcome.environment"
        }
        public struct Login {
            public static let submit = "id.login.submit"
            public static let submitNew = "id.login.submit.new"
            public static let username = "id.login.username"
            public static let password = "id.login.submit"
            public struct Error {
                public static let banner = "id.login.error.banner"
            }
        }
        public struct Permissions {
            public static let submit = "id.permissions.ok.button"
        }
        public struct Dashboard {
            public static let menu = "id.dashboard.menu"
        }
        public struct Menu {
            public static let logout = "id.menu.logout"
        }
        public struct Dialog {
            public static let destructive = "id.dialog.destructive.button"
        }
    }
}
