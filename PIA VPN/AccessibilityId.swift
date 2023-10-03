
import Foundation

public struct AccessibilityId {
  public struct VPNPermission {
    public static let screen = "id.vpnPermission.screen"
  }
}



/// This is the same struct `Accessibility` from `PIALibrary`
/// It has been copied over to the VPN ios client app to
/// facilitate e2e testing.
/// In the future, we will move the Welcome and Login ViewControllers and storyboards from `PIALibrary` into vpn ios
/// And this duplication will not be necessary
public struct PIALibraryAccessibility {
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

