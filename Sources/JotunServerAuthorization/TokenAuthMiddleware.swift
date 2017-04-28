//
//  TokenAuthMiddleware.swift
//  JotunServer
//
//  Created by Sergey on 4/13/17.
//
//

import Foundation
import Kitura
import LoggerAPI
import SwiftyJSON

extension Collection where Indices.Iterator.Element == Index {
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

public final class TokenAuthMiddleware: RouterMiddleware {
    private let userStore: JotunUsersStoreProvider
    public init(userStore: JotunUsersStoreProvider) {
        self.userStore = userStore
    }
    
    public func handle(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        guard let authorizationHeader = request.headers["Authorization"] else {
            try response.status(.unauthorized).send("Unauthorized. Authorization header is needed.").end()
            return
        }
        
        let authorizationHeaderComponents = authorizationHeader.components(separatedBy: " ")
        guard authorizationHeaderComponents[0] == "Bearer" else {
            try response.status(.unauthorized).send("Unauthorized. Bearer key is not provided.").end()
            return
        }
        
        guard let token = authorizationHeaderComponents[safe: 1] else {
            try response.status(.unauthorized).send("No token provided").end()
            return
        }
        self.userStore.getUser(byToken: token) { (user, error) in
            guard let user = user else {
                do {
                    try response.status(.unauthorized).send("Bad token").end()
                } catch {
                    Log.error("Communication error: \(error)")
                }
                return
            }
            request.jotunUser = user
            next()
        }
    }
}
