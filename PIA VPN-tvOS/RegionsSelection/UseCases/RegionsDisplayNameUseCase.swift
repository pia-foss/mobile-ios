//
//  RegionsDisplayNameUseCase.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/8/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

protocol RegionsDisplayNameUseCaseType {
    func getDisplayName(for server: ServerType, amongst servers: [ServerType]) -> (title: String, subtitle: String)
}


class RegionsDisplayNameUseCase: RegionsDisplayNameUseCaseType {
    
    func getDisplayName(for server: ServerType, amongst servers: [ServerType]) -> (title: String, subtitle: String) {

        if isTheDefaultServer(server, amongst: servers) {
            // TODO: Localize "Default"
            return (title: server.name, subtitle: L10n.Localizable.Regions.ListItem.Default.title)
        } else {
            return (title: server.country, subtitle: getDisplaySubtitleForNonDefault(server: server))
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
