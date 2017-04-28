//
//  JotunUserId.swift
//  JotunServerAuthorization
//
//  Created by Sergey Krasnozhon on 4/28/17.
//  Copyright © 2017 Sergey Krasnozhon. All rights reserved.
//
//

import Foundation
import SwiftyJSON

//Here could be placed some validators.
//First of all this is needed to prevent plain string passing.
public struct JotunUserId {
    public struct ParametersKeys {
        private init() {}
        public static let value = "value"
    }
    
    public let value: String
    
    public static func fromJson(_ json: JSON) -> JotunUserId? {
        guard let value = json[ParametersKeys.value].string else { return nil }
        return JotunUserId(value: value)
    }
    
    public func toJson() -> JSON {
        return JSON([
            ParametersKeys.value: self.value
            ])
    }
}
