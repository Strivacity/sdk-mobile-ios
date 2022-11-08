//
//  JwksUrlParser.swift
//  Strivacity
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation

/**
 * Represents the data obtained from the jwks url.
 */
class JwksUrlData: Equatable {
    /// identifies the cryptographic algorithm used to secure the json web signature
    let algorithm: String
    /// exponent of RSA public key
    let exponent: String
    /// key identifier
    let keyId: String
    /// key type
    let keyType: String
    /// modulus of RSA public key
    let modulus: String
    /// key usage description
    let usage: String
    
    /**
      Initialises JwksUrlData object
     
      - Parameters:
        - algorithm: algorithm used for the signing process
        - exponent: exponent of RSA public key
        - keyId: key identifier
        - keyType: key type
        - modulus: modulus of RSA public key
        - usage: key usage description
     */
    init(algorithm: String = "", exponent: String = "", keyId: String = "", keyType: String = "", modulus: String = "", usage: String = "") {
        self.algorithm = algorithm
        self.exponent = exponent
        self.keyId = keyId
        self.keyType = keyType
        self.modulus = modulus
        self.usage = usage
    }
    
    /**
      Implementation of the Equatable protocol, to be able to compare [JwksUrlData] objects.
     
      - Parameters:
        - lhs: first object
        - rhs: second object
     
      - Returns: Boolean value, true if the objects are equal, false otherwise.
     */
    static func == (lhs: JwksUrlData, rhs: JwksUrlData) -> Bool {
        lhs.algorithm == rhs.algorithm &&
        lhs.exponent == rhs.exponent &&
        lhs.keyId == rhs.keyId &&
        lhs.keyType == rhs.keyType &&
        lhs.modulus == rhs.modulus &&
        lhs.usage == rhs.usage
    }
}
