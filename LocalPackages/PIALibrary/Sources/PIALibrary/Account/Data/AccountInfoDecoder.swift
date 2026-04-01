
import Foundation

protocol AccountInfoDecoderType {
    func decodeAccountInfo(from data: Data) -> AccountInfo?
}

class AccountInfoDecoder: AccountInfoDecoderType {
    private let jsonDecoder = JSONDecoder()
    
    func decodeAccountInfo(from data: Data) -> AccountInfo? {
        jsonDecoder.dateDecodingStrategy = .secondsSince1970
       return try? jsonDecoder.decode(AccountInfo.self, from: data)
    }
    
    
}
