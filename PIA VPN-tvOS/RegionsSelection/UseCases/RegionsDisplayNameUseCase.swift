//
//  RegionsDisplayNameUseCase.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/8/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

protocol RegionsDisplayNameUseCaseType {
    
    func getDisplayName(for server: ServerType) -> (title: String, subtitle: String)
    
    func getDisplayName(for server: ServerType, amongst servers: [ServerType]) -> (title: String, subtitle: String)
    
    func getDisplayNameForOptimalLocation(with targetLocation: ServerType?) -> (title: String, subtitle: String)
}


class RegionsDisplayNameUseCase: RegionsDisplayNameUseCaseType {
    
    func getDisplayName(for server: ServerType, amongst servers: [ServerType]) -> (title: String, subtitle: String) {

        guard !servers.isEmpty else {
            return (title: server.country, subtitle: server.name)
        }
        
        if server.dipToken != nil {
            return (title: L10n.Localizable.Settings.Dedicatedip.Stats.dedicatedip, subtitle: server.name)
        } else if isTheDefaultServer(server, amongst: servers) {
            return (title: server.name, subtitle: L10n.Localizable.Regions.ListItem.Default.title)
        } else {
            return (title: server.country, subtitle: getDisplaySubtitleForNonDefault(server: server))
        }
    }
    
    func getDisplayName(for server: ServerType) -> (title: String, subtitle: String) {
        return getDisplayName(for: server, amongst: [])
    }
    
    func getDisplayNameForOptimalLocation(with targetLocation: ServerType?) -> (title: String, subtitle: String) {
        if let targetLocation {
            return (title: L10n.Localizable.LocationSelection.OptimalLocation.title, subtitle: targetLocation.name)
        } else {
            return (title: L10n.Localizable.LocationSelection.OptimalLocation.title, subtitle: L10n.Localizable.Global.automatic)
        }
        
    }
    
}

// MARK: - Private

extension RegionsDisplayNameUseCase {
    
    private func isTheDefaultServer(_ server: ServerType, amongst servers: [ServerType]) -> Bool {
        
        let serversInSameCountry = servers.filter {
            $0.country == server.country
        }
        
        return serversInSameCountry.count == 1
    }
    
    private func getDisplaySubtitleForNonDefault(server: ServerType) -> String {
        var nameWords = server.name.split(separator: " ")
        if let firstWord = nameWords.first,
           firstWord == server.country {
            nameWords.removeFirst()
            return nameWords.joined(separator: " ").capitalizedSentence
        } else {
            return server.name
        }
        
    }
    
}
