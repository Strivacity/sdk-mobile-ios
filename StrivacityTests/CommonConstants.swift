//
//  CommonConstants.swift
//  StrivacityTests
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation
@testable import Strivacity

class TestConstants {
    static let testKeyId = "test_key_id"
    static let wrongKeyId = "wrong_key_id"
    static let testKeyType = "test_key_type"
    static let testAlgorithm = "test_algorithm"
    static let testExponent = "test_exponent"
    static let testModulus = "test_modulus"
    static let testUsage = "test_usage"
    static let testSid = "test_sid"
    
    static let testDomainWithHttps = "https://www.example.com"
    static let testClientId = "test_client_id"
    static let wrongClientId = "wrong_client_id"
    static let testClientSecret = "test_client_secret"
    static let testRedirectUri = "https://www.example.com/redirect_uri"
    static let testAuthCode = "test_auth_code"
    static let testCodeVerifier = "test_code_verifier"
    
    static let testUserId = "test_user_id"
    static let testSubject = "test_subject"
    static let testCHash = "test_chash"
    static let testIssuer = "https://www.example.com/"
    static let testJwtId = "test_jwt_id"
    static let testNonce = "test_nonce"
    static let wrongNonce = "wrong_nonce"
    static let testAuthTime = Date(timeInterval: -10, since: Date(timeIntervalSinceNow: 0))
    static let testExpTime = Date(timeInterval: 10, since: Date(timeIntervalSinceNow: 0))
    static let testRatTime = Date(timeInterval: 10, since: Date(timeIntervalSinceNow: 0))
    static let testIatTime = Date(timeInterval: 10, since: Date(timeIntervalSinceNow: 0))
    static let invalidExpTime = Date(timeIntervalSinceNow: 0)
    static let testDomain = "www.example.com"
    static let wrongDomain = "wrong_domain"
    
    static let validJwksUrl = URL(string: "https://www.example.com/.well-known/jwks.json")!
    static let wrongJwksUrl = URL(string: "https://www.example.com/.wrong/jwks.json")!
    static let validTestConfig = Config(clientId: testClientId, clientSecret: testClientSecret, domain: testDomain, redirectUri: testRedirectUri)
    static let wrongDomainConfig = Config(clientId: testClientId, clientSecret: testClientSecret, domain: "", redirectUri: testRedirectUri)
    static let wrongRedirectUriConfig = Config(clientId: testClientId, clientSecret: testClientSecret, domain: testDomain, redirectUri: "")
    static let validJwksUrlData = JwksUrlData(algorithm: testAlgorithm, exponent: testExponent, keyId: testKeyId, keyType: testKeyType, modulus: testModulus, usage: testUsage)
    static let invalidJwksUrlData = JwksUrlData(algorithm: testAlgorithm, exponent: testExponent, keyId: wrongKeyId, keyType: testKeyType, modulus: testModulus, usage: testUsage)
    static let hybridFlowResponsePart = "com.exampletest.app://oauth2redirect#id_token="
    static let httpsScheme = "https"
}


class TestObject {
    
}
