//
//  JotunUserInMemoryPersistor.swift
//  JotunServerAuthorization
//
//  Created by Sergey Krasnozhon on 4/28/17.
//  Copyright © 2017 Sergey Krasnozhon. All rights reserved.
//
//

import Foundation

final class JotunUserInMemoryPersistor: JotunUserPersisting {
    private var credentials = [String: JotunUserCredentials]()
    private var tokens = [String: JotunUserToken]()
    
    static var shared: JotunUserInMemoryPersistor = {
        return JotunUserInMemoryPersistor()
    }()
    
    // MARK: JotunUserPersisting
    func create(credentials: JotunUserCredentials, oncomplete: @escaping (JotunUserPersistingError?) -> Void) {
        self.credentials[credentials.userId.value] = credentials
        oncomplete(nil)
    }
    
    func create(token: JotunUserToken, oncomplete: @escaping (JotunUserPersistingError?) -> Void) {
        self.tokens[token.value] = token
        oncomplete(nil)
    }
    
    func userCredentials(forTokenValue value: String, oncomplete: @escaping (JotunUserCredentials?, JotunUserPersistingError?) -> Void) {
        self.userByToken(value) { (userId, error) in
            guard let userId = userId else {
                return oncomplete(nil, .invalidUserForToken)
            }
            
            self.userCredentials(forUser: userId, oncomplete: { (credentials, error) in
                oncomplete(credentials, nil)
            })
        }
    }
    
    func userByToken(_ tokenValue: String, oncomplete: @escaping (JotunUserId?, JotunUserPersistingError?) -> Void) {
        oncomplete(self.tokens[tokenValue]?.userId, .invalidUserForToken)
    }
    
    func userCredentials(forUser userId: JotunUserId, oncomplete: @escaping (JotunUserCredentials?, JotunUserPersistingError?) -> Void) {
        oncomplete(self.credentials[userId.value], nil)
    }
    
    func deleteExpiredTokens(for user: JotunUserId) {
        
    }
}
