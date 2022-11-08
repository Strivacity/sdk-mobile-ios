//
//  IdTokenData.swift
//  StrivacityTests
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation
import XCTest
@testable import Strivacity

class IdTokenData: XCTest {
    
    static let invalidIdTokenString = "wrong_token_structure, valid token should contain 2 dots which separate header, payload an signature."
    static let validHeader: IdTokenHeader = IdTokenHeader(kid: TestConstants.testKeyId, alg: TestConstants.testAlgorithm)
    
    static let validPayload: IdTokenPayload = IdTokenPayload(sid: TestConstants.testSid,
                                                             authTime: TestConstants.testAuthTime,
                                                             expTime: TestConstants.testExpTime,
                                                             ratTime: TestConstants.testRatTime,
                                                             iatTime: TestConstants.testIatTime,
                                                             clientId: TestConstants.testClientId,
                                                             userId: TestConstants.testUserId,
                                                             subject: TestConstants.testSubject,
                                                             cHash: TestConstants.testCHash,
                                                             audience: TestConstants.testClientId,
                                                             issuer: TestConstants.testIssuer,
                                                             jwtId: TestConstants.testJwtId,
                                                             nonce: TestConstants.testNonce)
    static let validSignature = "test_signature"
    static let validIdToken: IdToken = IdToken(header: validHeader, payload: validPayload, signature: validSignature, isWellFormedToken: true)
    static let invalidIdToken = IdToken(header: IdTokenHeader(), payload: IdTokenPayload(), signature: "", isWellFormedToken: false)
    
    class func createValidIdTokenString() -> String {
        let headerString = IdTokenData.createValidHeaderString()
        let payloadString = IdTokenData.createValidPayloadString()
        let signature = IdTokenData.createValidSignatureString()
        
        return headerString + "." + payloadString + "." + signature
    }
    
    class func createInvalidIdTokenString(shouldHaveValidHeader: Bool, shouldHaveValidPayload: Bool) -> String {
        let headerString = shouldHaveValidHeader ? IdTokenData.createValidHeaderString() : IdTokenData.createInvalidHeaderString()
        let payloadString = shouldHaveValidPayload ? IdTokenData.createValidPayloadString() : IdTokenData.createInvalidPayloadString()
        let signature = IdTokenData.createValidSignatureString()
        
        return headerString + "." + payloadString + "." + signature
    }
    
    class func createInvalidIdTokenString(shouldHaveEmptyHeader: Bool, shouldHaveEmptyPayload: Bool) -> String {
        let headerString = shouldHaveEmptyHeader ? IdTokenData.createEmptyHeaderString() : IdTokenData.createValidHeaderString()
        let payloadString = shouldHaveEmptyPayload ? IdTokenData.createEmptyPayloadString() : IdTokenData.createValidPayloadString()
        let signature = IdTokenData.createValidSignatureString()
        
        return headerString + "." + payloadString + "." + signature
    }
    
    class func createIdTokenWithInvalidExpDateInPayload() -> String {
        return IdTokenData.createValidHeaderString() + "." + IdTokenData.createPayloadWithInvalidExpDateString() + "." + IdTokenData.validSignature
    }
    
    class func createBase64UrlString(from dictionary: Dictionary<String, Any>) -> String {
        let base64String = try? JSONSerialization.data(withJSONObject: dictionary).base64EncodedString()
        return base64String?.base64ToBase64Url() ?? ""
    }
    
    class func createValidHeaderString() -> String {
        let headerDictionary = Dictionary(dictionaryLiteral: (Constants.keyIdKey, TestConstants.testKeyId), (Constants.algorithmKey, TestConstants.testAlgorithm))
        return IdTokenData.createBase64UrlString(from: headerDictionary)
    }
    
    class func createInvalidHeaderString() -> String {
        return "invalid_header"
    }
    
    class func createEmptyHeaderString() -> String {
        return " "
    }
    
    class func createValidPayloadString() -> String {
        let payloadDictionary: Dictionary<String, Any> = Dictionary(dictionaryLiteral:
                                                                        (Constants.sidKey, TestConstants.testSid),
                                                                    (Constants.authTimeKey, Int(TestConstants.testAuthTime.timeIntervalSinceNow)),
                                                                    (Constants.expTimeKey, Int(TestConstants.testExpTime.timeIntervalSinceNow)),
                                                                    (Constants.ratTimeKey, Int(TestConstants.testRatTime.timeIntervalSinceNow)),
                                                                    (Constants.iatTimeKey, Int(TestConstants.testIatTime.timeIntervalSinceNow)),
                                                                    (Constants.clientIdKey, TestConstants.testClientId),
                                                                    (Constants.userIdKey, TestConstants.testUserId),
                                                                    (Constants.subjectKey, TestConstants.testSubject),
                                                                    (Constants.cHashKey, TestConstants.testCHash),
                                                                    (Constants.audKey, [TestConstants.testClientId]),
                                                                    (Constants.issuerKey, TestConstants.testIssuer),
                                                                    (Constants.jwtIdKey, TestConstants.testJwtId),
                                                                    (Constants.nonceKey, TestConstants.testNonce))
        return IdTokenData.createBase64UrlString(from: payloadDictionary)
    }
    
    class func createPayloadWithInvalidExpDateString() -> String {
        let payloadDictionary: Dictionary<String, Any> = Dictionary(dictionaryLiteral:
                                                                        (Constants.sidKey, TestConstants.testSid),
                                                                    (Constants.authTimeKey, Int(TestConstants.testAuthTime.timeIntervalSinceNow)),
                                                                    (Constants.expTimeKey, Int(TestConstants.invalidExpTime.timeIntervalSinceNow)),
                                                                    (Constants.ratTimeKey, Int(TestConstants.testRatTime.timeIntervalSinceNow)),
                                                                    (Constants.iatTimeKey, Int(TestConstants.testIatTime.timeIntervalSinceNow)),
                                                                    (Constants.clientIdKey, TestConstants.testClientId),
                                                                    (Constants.userIdKey, TestConstants.testUserId),
                                                                    (Constants.subjectKey, TestConstants.testSubject),
                                                                    (Constants.cHashKey, TestConstants.testCHash),
                                                                    (Constants.audKey, [TestConstants.testClientId]),
                                                                    (Constants.issuerKey, TestConstants.testIssuer),
                                                                    (Constants.jwtIdKey, TestConstants.testJwtId),
                                                                    (Constants.nonceKey, TestConstants.testNonce))
        return IdTokenData.createBase64UrlString(from: payloadDictionary)
    }
    
    class func createInvalidPayloadString() -> String {
        return "invalid_payload"
    }
    
    class func createEmptyPayloadString() -> String {
        return " "
    }
    
    class func createValidSignatureString() -> String {
        let signature = try? JSONSerialization.data(withJSONObject: validSignature, options: .fragmentsAllowed).base64EncodedString().base64ToBase64Url()
        return signature ?? ""
    }
}
