//
//  IdTokenHeader.swift
//  Strivacity
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation

/**
 * Represents the header component of the id token obtained via the AppAuth framework.
 */
class IdTokenHeader: Equatable {
    /// is a hint indicating which key was used to secure the json web signature
    let kidProperty: String
    /// identifies the cryptographic algorithm used to secure the json web signature
    let algProperty: String
    
    /**
    Initialises IdTokenHeader object
     
      - Parameters:
        - kid: key identifier
        - alg: algorithm
     */
    init(kid: String = "", alg: String = "") {
        self.kidProperty = kid
        self.algProperty = alg
    }
    
    /**
    Implementation of the Equatable protocol, to be able to compare [IdTokenHeader] objects.
    
      - Parameters:
        - lhs: first object
        - rhs: second object
     
      - Returns: Boolean value, true if the objects are equal, false otherwise.
     */
    static func == (lhs: IdTokenHeader, rhs: IdTokenHeader) -> Bool {
        return lhs.kidProperty == rhs.kidProperty && lhs.algProperty == rhs.algProperty
    }
}
