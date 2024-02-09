
import Foundation

extension String {
    static let kOnboardingVpnProfileInstalled = "kOnboardingVpnProfileInstalled"
}

extension String {
    var capitalizedSentence: String {
        // 1
        let firstLetter = self.prefix(1).capitalized
        // 2
        let remainingLetters = self.dropFirst().lowercased()
        // 3
        return firstLetter + remainingLetters
    }
}
