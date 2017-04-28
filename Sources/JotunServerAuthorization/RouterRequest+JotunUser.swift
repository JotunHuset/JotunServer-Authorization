//
//  RouterRequest+JotunUser.swift
//  JotunServerAuthorization
//
//  Created by Sergey Krasnozhon on 4/28/17.
//  Copyright © 2017 Sergey Krasnozhon. All rights reserved.
//
//

import Foundation
import Kitura

public extension RouterRequest {
    public internal(set) var jotunUser: JotunUserId? {
        get {
            return self.userInfo["@@Jotun@@UserInfo@@"] as? JotunUserId
        }
        set {
            self.userInfo["@@Jotun@@UserInfo@@"] = newValue
        }
    }
}
