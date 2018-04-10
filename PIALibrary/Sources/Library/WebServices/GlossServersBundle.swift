//
//  ServersBundle+Gloss.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/10/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import Gloss

class ServersResponse {
    private let originalLength: Int

    private let jsonString: String
    
    private let signature: Data

    init?(data: Data) {
        guard let dirtyString = String(data: data, encoding: .utf8) else {
            return nil
        }
        let dirtyLines = dirtyString.components(separatedBy: "\n\n")
        guard let jsonString = dirtyLines.first, let signatureString = dirtyLines.last else {
            return nil
        }
        guard let signature = Data(base64Encoded: signatureString, options: .ignoreUnknownCharacters) else {
            return nil
        }
        
        originalLength = data.count
        self.jsonString = jsonString
        self.signature = signature
    }
    
    func verifySignature(publicKey: SecKey) -> Bool {
        guard let data = jsonString.data(using: .utf8) else {
            fatalError("Cannot encode jsonString to data")
        }
        return data.verifySHA256(withRSASignature: signature, publicKey: publicKey)
    }

    func writeBundle(to file: String) throws {
        try jsonString.write(toFile: file, atomically: true, encoding: .utf8)
    }

    func bundle() -> ServersBundle? {
        return GlossServersBundle(jsonString: jsonString)?.parsed
    }
}

class GlossServersBundle: GlossParser {
    class Configuration: GlossParser {
        class Ports: GlossParser {
            let parsed: ServersBundle.Configuration.Ports

            required init?(json: JSON) {
                guard let udp: [UInt16] = "udp" <~~ json else {
                    return nil
                }
                guard let tcp: [UInt16] = "tcp" <~~ json else {
                    return nil
                }
                
                parsed = ServersBundle.Configuration.Ports(
                    udp: udp,
                    tcp: tcp
                )
            }
        }
            
        let parsed: ServersBundle.Configuration
        
        required init?(json: JSON) {
            guard let vpnPorts: Ports = "vpn_ports" <~~ json else {
                return nil
            }
            guard let latestVersion: Int = "latest_version" <~~ json else {
                return nil
            }
            guard let pollIntervalSeconds: Int = "poll_interval" <~~ json else {
                return nil
            }
            var automaticIdentifiers: Set<String>?
            if let automaticIdentifiersArray: [String] = "auto_regions" <~~ json {
                automaticIdentifiers = Set(automaticIdentifiersArray)
            }

            parsed = ServersBundle.Configuration(
                vpnPorts: vpnPorts.parsed,
                latestVersion: latestVersion,
                pollInterval: pollIntervalSeconds * 1000,
                automaticIdentifiers: automaticIdentifiers
            )
        }
    }
    
    let parsed: ServersBundle
    
    convenience init?(jsonString: String) {
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }
        self.init(jsonData: data)
    }

    convenience init?(jsonFile: String) {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: jsonFile)) else {
            return nil
        }
        self.init(jsonData: data)
    }
    
    convenience init?(jsonData: Data) {
        guard let anyJSON = try? JSONSerialization.jsonObject(with: jsonData, options: []), let json = anyJSON as? JSON else {
            return nil
        }
        self.init(json: json)
    }

    // MARK: Decodable

    public required init?(json: JSON) {
        let glossConfiguration: GlossServersBundle.Configuration? = "info" <~~ json

        var servers: [Server] = []
        for (_, serverDict) in json {
            guard let serverJSON = serverDict as? JSON else {
                continue
            }
            guard let _ = serverJSON["country"] as? String else {
                continue
            }
            guard let server = GlossServer(json: serverJSON)?.parsed else {
                continue
            }
            servers.append(server)
        }
        servers.sort { $0.name < $1.name }

        parsed = ServersBundle(
            servers: servers,
            configuration: glossConfiguration?.parsed
        )
    }
}
