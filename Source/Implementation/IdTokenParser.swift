//
//  IdTokenParser.swift
//  Strivacity
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation

/**
 * Parses the id token string obtained via the AppAuth framework.
 */
class IdTokenParser: ITokenParser {
    /// header index in id token string
    private let headerIdx = 0
    /// payload index in id token string
    private let payloadIdx = 1
    /// signature index in id token string
    private let signatureIdx = 2
    /// default token components count
    private let defaultTokenPartsCount = 3
    /// token components separator
    private let tokenPartsSeparator: String.Element = "."
    
    /**
     Parses the id token string
     
      - Parameters:
        - stringToParse: The string obtained using AppAuth framework.
        - error: An error which can occur during the parsing
        (it is passed as inout parameter so, its value can be set inside the function).
     
       - Returns: Valid [IdToken] object is returned on success or nil on failure.
     */
    func parse(_ stringToParse: String, error: inout NSError?) -> IdToken? {
        let idTokenParts = stringToParse.split(separator: tokenPartsSeparator)
        if idTokenParts.count != defaultTokenPartsCount {
            error = APIError.wrongTokenStructure as NSError
            return nil
        }
        
        guard let header = parseHeader(String(idTokenParts[headerIdx]), error: &error), let payload = parsePayload(String(idTokenParts[payloadIdx]), error: &error) else {
            return nil
        }
        
        let signature = String(idTokenParts[signatureIdx])
        return IdToken(header: header, payload: payload, signature: signature, isWellFormedToken: true)
    }
    
    /**
     Parses the id token header string
     
      - Parameters:
        - header: The string represents the header of the id token.
        - error: An error which can occur during the parsing
        (it is passed as inout parameter so, its value can be set inside the function).
     
      - Returns: Valid [IdTokenHeader] object is returned on success or nil on failure.
     */
    private func parseHeader(_ header: String, error: inout NSError?) -> IdTokenHeader? {
        guard let dict = getDictionary(header) else {
            error = APIError.failedToParseIdTokenHeader as NSError
            return nil
        }
        
        return IdTokenHeader(kid: getStringValue(from: dict, for: Constants.keyIdKey), alg: getStringValue(from: dict, for: Constants.algorithmKey))
    }
    
    /**
      Parses the id token payload string
     
      - Parameters:
        - payload: The string represents the payload of the id token.
        - error: An error which can occur during the parsing
        (it is passed as inout parameter so, its value can be set inside the function).
     
      - Returns: Valid [IdTokenPayload] object is returned on success or nil on failure.
     */
    private func parsePayload(_ payload: String, error: inout NSError?) -> IdTokenPayload? {
        guard let dict = getDictionary(payload) else {
            error = APIError.failedToParseIdTokenPayload as NSError
            return nil
        }
        
        let sid = getStringValue(from: dict, for: Constants.sidKey)
        let authTime = getDateValue(from: dict, for: Constants.authTimeKey)
        let expTime =  getDateValue(from: dict, for: Constants.expTimeKey)
        let ratTime =  getDateValue(from: dict, for: Constants.ratTimeKey)
        let iatTime =  getDateValue(from: dict, for: Constants.iatTimeKey)
        let clientId = getStringValue(from: dict, for: Constants.clientIdKey)
        let userId = getStringValue(from: dict, for: Constants.userIdKey)
        let subject = getStringValue(from: dict, for: Constants.subjectKey)
        let cHash = getStringValue(from: dict, for: Constants.cHashKey)
        let audience = (dict[Constants.audKey] as? Array<String>)?.first ?? ""
        let issuer = getStringValue(from: dict, for: Constants.issuerKey)
        let jwtId = getStringValue(from: dict, for: Constants.jwtIdKey)
        let nonce = getStringValue(from: dict, for: Constants.nonceKey)
        
        return IdTokenPayload(sid: sid, authTime: authTime, expTime: expTime, ratTime: ratTime, iatTime: iatTime, clientId: clientId, userId: userId, subject: subject, cHash: cHash, audience: audience, issuer: issuer, jwtId: jwtId, nonce: nonce)
    }
    
    /**
      Creates Dictionary object from part of the id token string
     
      - Parameter base64UrlEncodedString: The part of the id token string (header or payload), it has the
      base64url format.
      In order to get human readable data, we need to convert the base64url string to base64 string,
      then create Data object with it, then this Data object can be used to create Dictionary.
     
      - Returns: Valid Dictionary object is returned on success or nil on failure.
     */
    private func getDictionary(_ base64UrlEncodedString: String) -> Dictionary<String, Any>? {
        let base64EncodedString = base64UrlEncodedString.base64UrlToBase64()
        guard let data = Data(base64Encoded: base64EncodedString) else {
            print("Base64 encoded string could not be converted to data")
            return nil
        }
        
        return try? JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, Any>
    }
    
    /**
      Gets string value from dictionary
     
      - Parameters:
        - dictionary: The Dictionary object which contains values
        - key: The key which is used to obtain value from the dictionary.
     
      - Returns: String value is returned on success or empty string on failure.
     */
    private func getStringValue(from dictionary: Dictionary<String, Any>, for key: String) -> String {
        if let stringValue = dictionary[key] as? String {
            return stringValue
        }
        
        return ""
    }
    
    /**
      Gets Date value from dictionary
     
      - Parameters:
        - dictionary: The Dictionary object which contains values
        - key: The key which is used to obtain value from the dictionary.
     
      - Returns: Date value is returned, it contains valid date on success or current date on failure.
     */
    private func getDateValue(from dictionary: Dictionary<String, Any>, for key: String) -> Date {
        if let value = (dictionary[key] as? NSNumber)?.doubleValue {
            return Date(timeIntervalSinceNow: value)
        }
        
        return Date(timeIntervalSinceNow: 0)
    }
}
