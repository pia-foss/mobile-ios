//
//  SignupMetadata.swift
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 5/9/18.
//  Copyright © 2018 London Trust Media. All rights reserved.
//

import Foundation
import UIKit

struct SignupMetadata {
    var email: String
    
    var user: UserAccount?

    var title: String?
    
    var bodyImage: UIImage?
    
    var bodyImageOffset: CGPoint?

    var bodyTitle: String?
    
    var bodySubtitle: String?
    
    init(email: String, user: UserAccount? = nil) {
        self.email = email
        self.user = user
    }
}
