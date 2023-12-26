
import Foundation
import PIALibrary

protocol SelectedServerUseCaseType {
    func getSelectedServer() -> ServerType
}

class SelectedServerUseCase: SelectedServerUseCaseType {
    func getSelectedServer() -> ServerType {
        // TODO: get real server
        Server(
            serial: "",
            name: L10n.Localizable.Global.automatic,
            country: "universal",
            hostname: "auto.bogus.domain",
            pingAddress: nil,
            regionIdentifier: "auto"
        )
    }
}


