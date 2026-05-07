import Foundation

enum KPIUtils {
    static func isErrorStatusCode(_ code: Int) -> Bool {
        switch code {
        case 300...399, 400...499, 500...599: return true
        default: break
        }
        if code >= 600 { return true }
        return false
    }
}

extension String {
    func snakeToPascalCase() -> String {
        components(separatedBy: "_")
            .map { $0.capitalizedFirst().trimmingCharacters(in: .whitespaces) }
            .joined()
    }

    fileprivate func capitalizedFirst() -> String {
        guard let first else { return self }
        return String(first).uppercased() + dropFirst()
    }
}
