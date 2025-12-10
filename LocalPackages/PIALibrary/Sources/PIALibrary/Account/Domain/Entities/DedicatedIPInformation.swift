
import Foundation

public struct DedicatedIPInformation: Codable {
    enum Status: String, Codable {
        case active, expired, invalid, error
    }
    
    let id: String?
    let ip: String?
    let cn: String?
    let groups: [String]?
    let dipExpire: Double?
    let dipToken: String
    let status: DedicatedIPInformation.Status
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case ip = "ip"
        case cn = "cn"
        case groups = "groups"
        case dipExpire = "dip_expire"
        case dipToken = "dip_token"
        case status = "status"
    }
    
    //Expiring in 5 days or less
    var isAboutToExpire: Bool {
        guard let dipExpire, let nextDays = Calendar.current.date(byAdding: .day, value: 5, to: Date())
        else {
            return true
        }
        
        let expiringDate = Date(timeIntervalSince1970: TimeInterval(dipExpire))
        return nextDays >= expiringDate
    }
    
    static func makeWith(data: Data) -> [DedicatedIPInformation]? {
        let utfDataString = String(data: data, encoding: .utf8)
        guard let utfDataString else { return nil }
        
        let jsonStringComponents = utfDataString.split(separator: "\r\n")
        
        let jsonString = jsonStringComponents.filter {
            $0.starts(with: "[") && $0.contains("]")
        }.first
        
        guard let jsonString, let jsonData = jsonString.data(using: .utf8) else { return nil }
        
        return try? JSONDecoder().decode([DedicatedIPInformation].self, from: jsonData)
    }
}
