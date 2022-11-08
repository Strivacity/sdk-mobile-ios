//
//  IdTokenPayload.swift
//  Strivacity
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation

/**
 * Represents the payload component of the id token obtained via the AppAuth framework.
 */
class IdTokenPayload: Equatable {
    let sidProperty: String
    /// denotes when the user was authenticated
    let authTimeProperty: Date
    /// expiration time identifies the expiration time on or after which the id token must not be accepted for processing
    let expProperty: Date
    let ratProperty: Date
    /// issued at claim identifies the time at which the id token was issued
    let iatProperty: Date
    /// specifies client id
    let clientIdProperty: String
    /// specifies user id
    let userIdProperty: String
    /// identifies the principal that is the subject of the id token
    let subProperty: String
    /// code hash value
    let cHashProperty: String
    /// identifies the recipients that the id token is intended for
    let audProperty: String
    /// identifies the principal that issued the id token
    let issProperty: String
    /// unique identifier for the json web token
    let jtiProperty: String
    /// string value used to associate a Client session with an id token, and to mitigate replay attacks
    let nonceProperty: String

    init(sid: String = "", authTime: Date = Date(timeIntervalSinceReferenceDate: 0), expTime: Date = Date(timeIntervalSinceReferenceDate: 0), ratTime: Date = Date(timeIntervalSinceReferenceDate: 0), iatTime: Date = Date(timeIntervalSinceReferenceDate: 0), clientId: String = "", userId: String = "", subject: String = "", cHash: String = "", audience: String = "", issuer: String = "", jwtId: String = "", nonce: String = "") {
        self.sidProperty = sid
        self.authTimeProperty = authTime
        self.expProperty = expTime
        self.ratProperty = ratTime
        self.iatProperty = iatTime
        self.clientIdProperty = clientId
        self.userIdProperty = userId
        self.subProperty = subject
        self.cHashProperty = cHash
        self.audProperty = audience
        self.issProperty = issuer
        self.jtiProperty = jwtId
        self.nonceProperty = nonce
    }
    
    /**
      Implementation of the Equatable protocol, to be able to compare [IdTokenPayload] objects.
     
      - Parameters:
        - lhs: first object
        - rhs: second object
     
      - Returns: Boolean value, true if the objects are equal, false otherwise.
     */
    static func == (lhs: IdTokenPayload, rhs: IdTokenPayload) -> Bool {
        return Int(lhs.authTimeProperty.timeIntervalSinceNow) == Int(rhs.authTimeProperty.timeIntervalSinceNow) &&
        Int(lhs.expProperty.timeIntervalSinceNow) == Int(rhs.expProperty.timeIntervalSinceNow) &&
        Int(lhs.ratProperty.timeIntervalSinceNow) == Int(rhs.ratProperty.timeIntervalSinceNow) &&
        Int(lhs.iatProperty.timeIntervalSinceNow) == Int(rhs.iatProperty.timeIntervalSinceNow) &&
        lhs.sidProperty == rhs.sidProperty &&
        lhs.clientIdProperty == rhs.clientIdProperty &&
        lhs.userIdProperty == rhs.userIdProperty &&
        lhs.subProperty == rhs.subProperty &&
        lhs.cHashProperty == rhs.cHashProperty &&
        lhs.audProperty == rhs.audProperty &&
        lhs.issProperty == rhs.issProperty &&
        lhs.jtiProperty == rhs.jtiProperty &&
        lhs.nonceProperty == rhs.nonceProperty
    }
}
