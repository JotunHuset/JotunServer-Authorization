//
//  JotunUserCredentials.swift
//  JotunServer
//
//  Created by Sergey on 4/25/17.
//
//

import Foundation
import SwiftyJSON

public struct JotunUserCredentials {
    public struct ParametersKeys {
        private init() {}
        public static let userId = "userId"
        public static let salt = "salt"
        public static let encodedPassword = "encodedPassword"
        public static let saltLength = "saltLength"
        public static let roundsOfPBKDF = "roundsOfPBKDF"
    }
    
    public let userId: JotunUserId
    public let salt: String
    public let encodedPassword: String
    public let saltLength: UInt
    public let roundsOfPBKDF: UInt32
    
    public static func fromJson(_ json: JSON) -> JotunUserCredentials? {
        let userIdJson = json[ParametersKeys.userId]
        guard let userId = JotunUserId.fromJson(userIdJson),
            let salt = json[ParametersKeys.salt].string,
            let encodedPassword = json[ParametersKeys.encodedPassword].string,
            let saltLenght = json[ParametersKeys.saltLength].uInt,
            let roundsOfPBKDF = json[ParametersKeys.roundsOfPBKDF].uInt32 else { return nil }
        
        return JotunUserCredentials(userId: userId, salt: salt, encodedPassword: encodedPassword,
                                    saltLength: saltLenght, roundsOfPBKDF: roundsOfPBKDF)
    }
    
    public func toJson() -> JSON {
        return JSON([
            ParametersKeys.encodedPassword: self.encodedPassword,
            ParametersKeys.roundsOfPBKDF: self.roundsOfPBKDF,
            ParametersKeys.salt: self.salt,
            ParametersKeys.saltLength: self.saltLength,
            ParametersKeys.userId: self.userId.toJson().dictionaryObject ?? [:]
            ])
    }
}
