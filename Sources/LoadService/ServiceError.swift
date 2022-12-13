//
//  ServiceError.swift
//  
//
//  Created by Ivan Konishchev on 13.12.2022.
//

import Foundation

enum ServiceError: Error {
    case succes
    case userNotFound
    case internetConnectionFault
    case parseError
    case invalidUserId
    case invalidURL
    case responseError
    case jenericError
    case DBConnectionFailure
    case notRealmSwiftObject
}
