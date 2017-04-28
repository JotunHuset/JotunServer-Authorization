//
//  JotunUsersStoreProvider.swift
//  JotunServer
//
//  Created by Sergey on 4/25/17.
//
//

import Foundation
import MiniPromiseKit

public struct JotunUsersStoreProvider {
    private let persistor: JotunUserPersisting
    private let tokenExpirationSeconds: Double
    private let queue = DispatchQueue(label: "JotunUsersStoreProvider")
    
    public init(persistor: JotunUserPersisting, tokenExpirationSeconds: Double = 15 * 60) {
        self.persistor = persistor
        self.tokenExpirationSeconds = tokenExpirationSeconds
    }
    
    func createUser(user: JotunUserId, password: String, oncomplete: @escaping (TokenAuthError?) -> Void) {
        firstly {
            return self.userCredentialsPromise(forUser: user)
            }
            .then(on: self.queue) { (credentials) -> Void in
                if (credentials != nil) { throw TokenAuthError.userExist }
            }
            .then(on: self.queue) { () -> JotunUserCredentials? in
                return self.generateCredentials(forUser: user, password: password)
            }
            .then(on: self.queue) { (credentials) -> JotunUserCredentials in
                guard let credentials = credentials else { throw TokenAuthError.cantGenerateCredentials }
                return credentials
            }
            .then(on: self.queue) { (credentials) in
                return Promise<JotunUserPersistingError?> { (fulfill, _) in
                    self.persistor.create(credentials: credentials, oncomplete: { (error) in
                        fulfill(error)
                    })
                }
            }
            .then(on: self.queue) { (error) in
                if let error = error { throw error }
                oncomplete(nil)
            }
            .catch(on: self.queue) { (error) in
                oncomplete((error as? TokenAuthError) ?? TokenAuthError.generalError)
        }
    }

    func createToken(user: JotunUserId, password: String, oncomplete: @escaping (_ token: String?, TokenAuthError?) -> Void) {
        self.persistor.deleteExpiredTokens(for: user)
        firstly {
            return self.userCredentialsPromise(forUser: user)
            }
            .then(on: self.queue) { (credentials) -> Void in
                let isValid = self.isValidCredentials(credentials, withPassword: password)
                if !isValid { throw TokenAuthError.invalidLoginOrPassword }
            }
            .then(on: self.queue) { () -> JotunUserToken in
                let expiration = Date().timeIntervalSince1970 + self.tokenExpirationSeconds
                let token = JotunUserToken(value: UUID().uuidString, expireDate: expiration, userId: user)
                return token
            }
            .then(on: self.queue) { (token) in
                self.persistor.create(token: token, oncomplete: { (error) in
                    let resultError = (error == nil) ? nil : TokenAuthError.generalError
                    oncomplete(token.value, resultError)
                })
            }
            .catch(on: self.queue) { (error) in
                let resultError = (error as? TokenAuthError) ?? TokenAuthError.generalError
                oncomplete(nil, resultError)
        }
    }
    
    func getUser(byToken token: String, oncomplete: @escaping (JotunUserId?, TokenAuthError?) -> Void) {
        firstly {
            return self.userCredentialsPromise(forTokenValue: token)
            }
            .then(on: self.queue) { (credentials) -> Void in
                guard let userId = credentials?.userId else { throw TokenAuthError.invalidToken }
                self.persistor.deleteExpiredTokens(for: userId)
            }
            .then(on: self.queue) {
                return self.userCredentialsPromise(forTokenValue: token)
            }
            .then(on: self.queue) { (credentials) in
                guard let resultUserId = credentials?.userId else { throw TokenAuthError.expiredToken }
                oncomplete(resultUserId, nil)
            }
            .catch(on: self.queue) { (error) in
                let resultError = (error as? TokenAuthError) ?? TokenAuthError.generalError
                oncomplete(nil, resultError)
        }
    }
    
    // MARK:
    private func isValidCredentials(_ credentials: JotunUserCredentials?, withPassword password: String) -> Bool {
        guard let credentials = credentials else { return false }
        let generator = CredentialsGeneratorPBKDF(saltLength: credentials.saltLength,
                                                  roundsOfPBKDF: credentials.roundsOfPBKDF)
        let testEncodedPassword = generator.encodedPassword(fromSalt: credentials.salt, password: password)
        return (testEncodedPassword == credentials.encodedPassword)
    }
    
    private func generateCredentials(forUser user: JotunUserId, password: String) -> JotunUserCredentials? {
        let generator = CredentialsGeneratorPBKDF()
        guard let (salt, encodedPassword) = generator.generate(forPassword: password) else { return nil }
        let credentials = JotunUserCredentials(
            userId: user, salt: salt, encodedPassword: encodedPassword, saltLength: generator.saltLength,
            roundsOfPBKDF: generator.roundsOfPBKDF)
        return credentials
    }
    
    
    // MARK: Private
    private func userCredentialsPromise(forUser user: JotunUserId) -> Promise<JotunUserCredentials?> {
        return Promise<JotunUserCredentials?> { (fulfill, _) in
            self.persistor.userCredentials(forUser: user, oncomplete: { (credentials, _) in
                self.queue.sync { fulfill(credentials) }
            })
        }
    }
    
    private func userCredentialsPromise(forTokenValue value: String) -> Promise<JotunUserCredentials?> {
        return Promise<JotunUserCredentials?> { (fulfill, _) in
            self.persistor.userCredentials(forTokenValue: value, oncomplete: { (credentials, _) in
                self.queue.sync { fulfill(credentials) }
            })
        }
    }
}
