
import Foundation


protocol JSONToStringCoverterType {
    func stringify(json: [String: Any]?, prettyPrinted: Bool) -> String?
}

extension JSONToStringCoverterType {
    func stringify(json: [String: Any]?, prettyPrinted: Bool) -> String? {
        guard let json else {
            return nil
        }
        
        var options: JSONSerialization.WritingOptions = []
        if prettyPrinted {
            options = JSONSerialization.WritingOptions.prettyPrinted
        }

        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: options)
            if let string = String(data: data, encoding: String.Encoding.utf8) {
                return string
            }
        } catch {
            print(error)
        }

        return nil
    }
}

