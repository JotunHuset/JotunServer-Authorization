//
//  CredentialsGeneratorPBKDF.swift
//  JotunServerAuthorization
//
//  Created by Sergey Krasnozhon on 4/28/17.
//  Copyright © 2017 Sergey Krasnozhon. All rights reserved.
//
//

import Foundation
import Cryptor

/*
 Look here for parameters choose 
 https://cryptosense.com/parameter-choice-for-pbkdf2/
 */
struct CredentialsGeneratorPBKDF {
    let saltLength: UInt
    let roundsOfPBKDF: UInt32
    
    init(saltLength: UInt = 64, roundsOfPBKDF: UInt32 = 10000) {
        self.saltLength = saltLength
        self.roundsOfPBKDF = roundsOfPBKDF
    }
    
    func generate(forPassword password: String) -> (salt: String, encodedPassword: String)? {
        guard let salt = self.salt() else { return nil }
        guard let encodedPassword = self.encodedPassword(fromSalt: salt, password: password) else { return nil }
        return (salt, encodedPassword)
    }
    
    func encodedPassword(fromSalt salt: String, password: String) -> String? {
        let bytes: [UInt8] = PBKDF.deriveKey(fromPassword: password, salt: salt, prf: .sha512,
                                             rounds: self.roundsOfPBKDF, derivedKeyLength: self.saltLength)
        let encodedPassword = CryptoUtils.hexString(from: bytes)
        return encodedPassword
    }
    
    func salt() -> String? {
        guard let bytes: [UInt8] = try? Random.generate(byteCount: Int(self.saltLength)) else {
            return nil
        }
        let salt = CryptoUtils.hexString(from: bytes)
        return salt
    }
}
