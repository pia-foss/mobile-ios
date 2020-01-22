//
//  AboutComponent.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 3/25/18.
//  Copyright © 2020 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation

protocol AboutComponent: Equatable {
    var name: String { get }
}

struct NoticeComponent: AboutComponent {
    let name: String
    
    let copyright: String
    
    let notice: String
    
    fileprivate init(_ name: String, _ copyright: String, _ notice: String) {
        self.name = name
        self.copyright = copyright
        self.notice = notice
    }

    // MARK: Equatable

    static func ==(lhs: NoticeComponent, rhs: NoticeComponent) -> Bool {
        return (lhs.name == rhs.name)
    }
}

struct LicenseComponent: AboutComponent {
    let name: String
    
    let copyright: String
    
    let licenseURL: URL
    
    fileprivate init(_ name: String, _ copyright: String, _ licenseURL: URL) {
        self.name = name
        self.copyright = copyright
        self.licenseURL = licenseURL
    }

    // MARK: Equatable
    
    static func ==(lhs: LicenseComponent, rhs: LicenseComponent) -> Bool {
        return (lhs.name == rhs.name)
    }
}

struct Components {
    let notices: [NoticeComponent]
    
    let licenses: [LicenseComponent]

    init(_ plist: String) {
        guard let dict = NSDictionary(contentsOfFile: plist) else {
            fatalError("Malformed components plist")
        }

        var notices: [NoticeComponent] = []
        var licenses: [LicenseComponent] = []

        if let noticesList = dict["Notices"] as? NSArray {
            for nsDict in noticesList {
                guard let dict = nsDict as? NSDictionary else {
                    fatalError()
                }
                guard let name = dict["Name"] as? String else {
                    fatalError()
                }
                guard let copyright = dict["Copyright"] as? String else {
                    fatalError()
                }
                guard let notice = dict["Notice"] as? String else {
                    fatalError()
                }
                notices.append(NoticeComponent(name, copyright, notice))
            }
        }
        if let licensesList = dict["Licenses"] as? NSArray {
            for nsDict in licensesList {
                guard let dict = nsDict as? NSDictionary else {
                    fatalError()
                }
                guard let name = dict["Name"] as? String else {
                    fatalError()
                }
                guard let copyright = dict["Copyright"] as? String else {
                    fatalError()
                }
                guard let licenseURLString = dict["LicenseURL"] as? String, let licenseURL = URL(string: licenseURLString) else {
                    fatalError()
                }
                licenses.append(LicenseComponent(name, copyright, licenseURL))
            }
        }

        self.notices = notices
        self.licenses = licenses
    }
}
