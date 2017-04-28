//
//  RouterRequest+JotunUser.swift
//  JotunServer
//
//  Created by Sergey on 4/25/17.
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
