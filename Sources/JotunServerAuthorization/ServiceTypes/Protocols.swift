//
//  Protocols.swift
//  JotunServer
//
//  Created by Sergey on 4/27/17.
//
//

import Foundation

public protocol JutonCredentialsPersisting {
    func create(credentials: JotunUserCredentials, oncomplete: @escaping (JotunUserPersistingError?) -> Void)
    func userCredentials(forUser userId: JotunUserId, oncomplete: @escaping (JotunUserCredentials?, JotunUserPersistingError?) -> Void)
}

public protocol JotunTokensPersisting {
    func create(token: JotunUserToken, oncomplete: @escaping (JotunUserPersistingError?) -> Void)
    func userByToken(_ tokenValue: String, oncomplete: @escaping (JotunUserId?, JotunUserPersistingError?) -> Void)
    func deleteExpiredTokens(for user: JotunUserId)
}

public protocol JotunUserPersisting: JutonCredentialsPersisting, JotunTokensPersisting {
    func userCredentials(forTokenValue token: String, oncomplete: @escaping (JotunUserCredentials?, JotunUserPersistingError?) -> Void)
}
