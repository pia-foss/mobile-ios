
import Foundation

protocol ClientStatusInformationDecoderType {
    func decodeClientStatus(from data: Data) -> ClientStatusInformation?
}

class ClientStatusInformationDecoder: ClientStatusInformationDecoderType {
    
    private let jsonDecoder = JSONDecoder()
    
    func decodeClientStatus(from data: Data) -> ClientStatusInformation? {
        try? jsonDecoder.decode(ClientStatusInformation.self, from: data)
    }
}
