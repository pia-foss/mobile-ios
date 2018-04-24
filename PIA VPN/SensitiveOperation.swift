//
//  SensitiveOperation.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/15/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import LocalAuthentication

class SensitiveOperation {
    private let context: LAContext
    
    var canPerformInSensitiveContext: Bool
    
    init() {
        context = LAContext()
        canPerformInSensitiveContext = context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
    }
    
    func perform(withReason reason: String, completionHandler: @escaping () -> Void) {
        guard canPerformInSensitiveContext else {
            completionHandler()
            return
        }
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { (success, error) in
            guard success else {
                return
            }
            DispatchQueue.main.async {
                completionHandler()
            }
        }
    }
        
    static func perform(withReason reason: String, completionHandler: @escaping () -> Void) {
        SensitiveOperation().perform(withReason: reason, completionHandler: completionHandler)
    }
}
