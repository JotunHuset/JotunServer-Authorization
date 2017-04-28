//
//  JotunUserToken.swift
//  JotunServer
//
//  Created by Sergey on 4/25/17.
//
//

import Foundation
import SwiftyJSON

public struct JotunUserToken {
    public struct ParametersKeys {
        private init() {}
        public static let value = "value"
        public static let expireDate = "expireDate"
        public static let userId = "user"
    }

    public let value: String
    public let expireDate: Double
    public let userId: JotunUserId
    
    public static func fromJson(_ json: JSON) -> JotunUserToken? {
        let userIdJson = json[ParametersKeys.userId]
        guard let userId = JotunUserId.fromJson(userIdJson),
            let value = json[ParametersKeys.value].string,
            let expireDate = json[ParametersKeys.expireDate].double else { return nil }
        
        return JotunUserToken(value: value, expireDate: expireDate, userId: userId)
    }
    
    public func toJson() -> JSON {
        return JSON([
            ParametersKeys.value: self.value,
            ParametersKeys.expireDate: self.expireDate,
            ParametersKeys.userId: self.userId.toJson().dictionaryObject ?? [:]
            ])
    }
}
