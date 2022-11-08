//
//  IdToken.swift
//  Strivacity
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation

/**
 * Represents the id token obtained via the AppAuth framework.
 */
class IdToken: Equatable {
    /// Header of the id token
    private let header: IdTokenHeader
    /// Payload of the id token
    private let payload: IdTokenPayload
    /// Signature of the id token
    private let signature: String
    /// Variable indicates the correctness of the id token structure
    private let isWellFormedToken: Bool
    
    /**
    Initialises IdToken object
     
      - Parameters:
        - header: id token header
        - payload: id token payload
        - signature: id token signature
        - isWellFormedToken: correctness of the id token structure
     */
    init(header: IdTokenHeader, payload: IdTokenPayload, signature: String, isWellFormedToken: Bool) {
        self.header = header
        self.payload = payload
        self.signature = signature
        self.isWellFormedToken = isWellFormedToken
    }
    
    /**
     * Gets the data about token structure validness
     *
     * The token structure is valid if the token string consists of header, payload and signature separated with dots.
     *
     * - Returns: Boolean value, true if the token has valid structure, false otherwise.
     */
    func isWellFormed() -> Bool {
        isWellFormedToken
    }
    
    /**
     * Function provides IdTokenHeader
     *
     * - Returns: the [IdTokenHeader]
     */
    func getHeader() -> IdTokenHeader {
        header
    }
    
    /**
     * Function provides IdTokenPayload
     *
     * - Returns: the [IdTokenPayload]
     */
    func getPayload() -> IdTokenPayload {
        payload
    }
    
    /**
     * Function provides id token signature
     *
     * - Returns: the token signature.
     */
    func getSignature() -> String {
        signature
    }
    
    /**
    Implementation of the [Equatable] protocol, to be able to compare [IdToken] objects.

      - Parameters:
        - lhs: first IdToken object
        - rhs: second IdToken object
     
      - Returns: Boolean value, true if the objects are equal, false otherwise.
     */
    static func == (lhs: IdToken, rhs: IdToken) -> Bool {
        let isWellFormedPropertyEqual = lhs.isWellFormedToken == rhs.isWellFormedToken
        let areHeadersEqual = lhs.header == rhs.header
        return isWellFormedPropertyEqual && areHeadersEqual
    }
}
