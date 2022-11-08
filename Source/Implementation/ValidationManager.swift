//
//  ValidationManager.swift
//  Strivacity
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation
import CryptoKit

/**
 * Manages the id token validation.
 */
class ValidationManager: IValidationManager {
    /// object that parses id token string
    private let idTokenParser: ITokenParser
    /// object that manages jwks url data
    private let jwksUrlDataManager: IJwksUrlDataManager
    /// object handles public key creation
    private let publicKeyCreator: IPublicKeyCreator
    
    /**
      Initialises with objects that help to validate the id token string.
     
      - Parameters:
        - tokenParser: object that parses id token string
        - jwksUrlDataManager: object that manages jwks url data
        - publicKeyCreator: object handles public key creation
     */
    init(tokenParser: ITokenParser = IdTokenParser(), jwksUrlDataManager: IJwksUrlDataManager = JwksUrlDataManager(), publicKeyCreator: IPublicKeyCreator = PublicKeyCreator()) {
        self.idTokenParser = tokenParser
        self.jwksUrlDataManager = jwksUrlDataManager
        self.publicKeyCreator = publicKeyCreator
    }
    
    /**
      Validates the id token string
     
      - Parameters:
        - idTokenString: String value obtained using AppAuth framework and passed for validation.
        - authorizationCode: String value obtained using AppAuth framework and passed for validation.
        - clientId: used for id token validation.
        - nonce: used for id token validation.
        - config: used for id token validation.
        - jwksUrl: URL which contains data needed for validation process.
        - error: An error which can occur during the validation,
        (it is passed as inout parameter so, its value can be set inside the function).
     
      - Returns: Boolean value is returned, true on success or false on failure.
     */
    func validate(idTokenString: String?, authorizationCode: String?, clientId: String, nonce: String, jwksUrl: URL, config: Config, error: inout NSError?) -> Bool {
        guard let idTokenString = idTokenString else {
            error = APIError.failedToUnwrapIdTokenString as NSError
            print("Failed to unwrap idToken.")
            return false
        }
        
        guard let idToken = self.idTokenParser.parse(idTokenString, error: &error) else {
            print("Failed to parse idToken.")
            return false
        }
        
        guard let jwksUrlData = jwksUrlDataManager.obtainJwksUrlData(jwksUrl: jwksUrl, idTokenHeader: idToken.getHeader(), error: &error) else {
            print("Failed to obtain jwksUrl data.")
            return false
        }
        
        if !validateIdTokenHeader(idToken.getHeader(), keyId: jwksUrlData.keyId) {
            error = APIError.keyIdsAreDifferentError as NSError
            return false
        }
        
        if !validateIdTokenPayload(idToken.getPayload(), clientId: clientId, nonce: nonce, config: config) {
            error = APIError.failedToValidateIdTokenPayload as NSError
            return false
        }
        
        if publicKeyCreator.createPublicKey(modulus: jwksUrlData.modulus, exponent: jwksUrlData.exponent) == nil {
            error = APIError.failedToCreatePublicKey as NSError
            return false
        }
        
        if !validateAuthCode(authorizationCode ?? "", cHash: idToken.getPayload().cHashProperty) {
            error = APIError.failedToValidateAuthCode as NSError
            return false
        }
        
        return true
    }
    
    /**
      Validates the [IdTokenHeader] object.
     
      - Parameters:
        - header: [IdTokenHeader] object which is under validation.
        - keyId: String value which is obtained from jwks url.
      The header can be treated as valid if it's keyId property is equal to the keyId property obtained from jwks url.
     
      - Returns: Boolean value, true on success, false on failure.
     */
    private func validateIdTokenHeader(_ header: IdTokenHeader, keyId: String) -> Bool {
        return header.kidProperty == keyId
    }
    
    /**
      Validates the [IdTokenPayload] object.
      The payload can be treated as valid if:
      - it's client id and audience properties are equal to the client id obtained from OIDAuthorizationResponse object;
      - it's nonce property is equal to the property obtained from OIDAuthorizationResponse object;
      - it's issuer property is equal to the domain value stored in config;
      - it's expiration time property has the time which is after the current time.
     
      - Parameters:
        - payload: [IdTokenPayload] object which is under validation.
        - clientId: obtained from the OIDAuthorizationRequest object which contained inside the OIDAuthorizationResponse object.
        - nonce: obtained from the OIDAuthorizationRequest object which contained inside the OIDAuthorizationResponse object.
        - config: [Config] object that contains information required for the authentication.
     
      - Returns: Boolean value, true on success, false on failure.
     */
    private func validateIdTokenPayload(_ payload: IdTokenPayload, clientId: String, nonce: String, config: Config) -> Bool {
        if payload.clientIdProperty != clientId || payload.audProperty != clientId {
            return false
        } else if payload.nonceProperty != nonce {
            return false
        } else if payload.issProperty != Constants.httpsPrefix + config.domain + "/" {
            return false
        } else if payload.expProperty <= Date(timeIntervalSinceNow: 0) {
            return false
        }
        
        return true
    }
    
    /**
      Validates the authorization code,
      The authorization code can be treated as valid if base64 encoded string
      of the first 16 bits of the hash value of it's ASCII encoded data is equal to
      base64 encoded cHash string.
     
      - Parameters:
        - authCode: String value which is under validation.
        - cHash: String value which is obtained from [IdTokenPayload] object.
     
      - Returns: Boolean value, true on success, false on failure.
     */
    private func validateAuthCode(_ authCode: String, cHash: String) -> Bool {
        if let authCodeData = authCode.data(using: .ascii) {
            let digest = SHA256.hash(data: authCodeData)
            let hashedDigest = Data(digest).subdata(in: 0..<Constants.twoBytesInBitsCount)
            let base64EncodedString = hashedDigest.base64EncodedString()
            
            return base64EncodedString == cHash.base64UrlToBase64()
        }
        
        return false
    }
}
