//
//  AuthHandlersCreator.swift
//  JotunServer
//
//  Created by Sergey on 4/24/17.
//
//

import Foundation
import Kitura
import LoggerAPI
import SwiftyJSON

public struct AuthHandlersCreator {
    public enum ParametersContainer {
        case body, querry
    }
    
    public struct ParametersKeys {
        let userId: String
        let password: String
        
        // Allows to customize API parameters.
        static func base() -> ParametersKeys {
            return ParametersKeys(userId: "jotun_userId", password: "jotun_userPassword")
        }
    }
    
    private let userStore: JotunUsersStoreProvider
    private let parametersContainer: ParametersContainer
    private let parametersKeys: ParametersKeys
    
    public init(userStore: JotunUsersStoreProvider, parametersContainer: ParametersContainer,
         parametersKeys: ParametersKeys = ParametersKeys.base()) {
        self.userStore = userStore
        self.parametersContainer = parametersContainer
        self.parametersKeys = parametersKeys
    }
    
    public func registerHandler() -> RouterHandler {
        return { (request, response, _) in
            guard let credentials = self.parsedCredentials(from: request) else {
                try? response.status(.badRequest).send("Bad credentials").end()
                return
            }
            self.userStore.createUser(user: JotunUserId(value: credentials.userId), password: credentials.password) {
                (error) in
                let response = (error == nil) ? response.status(.OK).send("User created") :
                    response.status(.internalServerError).send("User not created")
                do {
                    try response.end()
                } catch {
                    Log.error("Communication error: \(error)")
                }
            }
        }
    }
    
    public func loginHandler() -> RouterHandler {
        return { (request, response, _) in
            guard let credentials = self.parsedCredentials(from: request) else {
                try? response.status(.badRequest).send("Bad credentials").end()
                return
            }
            self.userStore.createToken(
                user: JotunUserId(value: credentials.userId), password: credentials.password, oncomplete: {
                    (token, error) in
                    let response = (error == nil) ? response.status(.OK).send(json: JSON(["token": token])) :
                        response.status(.internalServerError).send("Token not created")
                    do {
                        try response.end()
                    } catch {
                        Log.error("Communication error: \(error)")
                    }
            })
        }
    }
    
    //MARK:
    private func parsedCredentials(from request: RouterRequest) -> (userId: String, password: String)? {
        let parameters: [String:String]
        switch self.parametersContainer {
        case .body: parameters = request.parameters
        case .querry: parameters = request.queryParameters
        }
        guard let userId = parameters[self.parametersKeys.userId],
            let password = parameters[self.parametersKeys.password] else {
                return nil
        }
        return (userId, password)
    }
}
