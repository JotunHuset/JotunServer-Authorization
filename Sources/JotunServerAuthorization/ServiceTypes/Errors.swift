//
//  Errors.swift
//  JotunServerAuthorization
//
//  Created by Sergey Krasnozhon on 4/28/17.
//  Copyright © 2017 Sergey Krasnozhon. All rights reserved.
//
//

import Foundation

public enum TokenAuthError: Error {
    case invalidLoginOrPassword
    case userExist
    case cantGenerateCredentials
    case invalidToken
    case expiredToken
    case generalError(Error)
}

public enum JotunUserPersistingError: Error {
    case invalidUserForToken
    case cantDuplicateUser
    case stogareError
    case extraRecordFound
    case generalError(Error)
}
