//
//  Errors.swift
//  JotunServer
//
//  Created by Sergey on 4/27/17.
//
//

import Foundation

public enum TokenAuthError: Error {
    case invalidLoginOrPassword
    case userExist
    case cantGenerateCredentials
    case invalidToken
    case expiredToken
    case generalError
}

public enum JotunUserPersistingError: Error {
    case invalidUserForToken
    case generalError
    case cantDuplicateUser
}
