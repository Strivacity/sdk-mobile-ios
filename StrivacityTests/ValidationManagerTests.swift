//
//  ValidationManagerTests.swift
//  StrivacityTests
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation
import AppAuth
import XCTest
@testable import Strivacity

class StubJwksUrlDataManagerValidData: IJwksUrlDataManager {
    func obtainJwksUrlData(jwksUrl: URL, idTokenHeader: IdTokenHeader, error: inout NSError?) -> JwksUrlData? {
        return TestConstants.validJwksUrlData
    }
}

class StubJwksUrlDataManagerInvalidData: IJwksUrlDataManager {
    func obtainJwksUrlData(jwksUrl: URL, idTokenHeader: IdTokenHeader, error: inout NSError?) -> JwksUrlData? {
        return TestConstants.invalidJwksUrlData
    }
}

class StubJwksUrlDataManagerNilData: IJwksUrlDataManager {
    func obtainJwksUrlData(jwksUrl: URL, idTokenHeader: IdTokenHeader, error: inout NSError?) -> JwksUrlData? {
        return nil
    }
}

class StubPublicKeyCreateInvalid: IPublicKeyCreator {
    func createPublicKey(modulus: String, exponent: String) -> SecKey? {
        return nil
    }
}

final class ValidationManagerTests: XCTestCase {
    var validationManager: IValidationManager?
    
    override func tearDown() {
        validationManager = nil
    }
    
    func testIdTokenIsNil() {
        validationManager = ValidationManager(jwksUrlDataManager: StubJwksUrlDataManagerValidData())
        var error: NSError?
        let result = validationManager?.validate(idTokenString: nil, authorizationCode: "", clientId: TestConstants.testClientId, nonce: TestConstants.testNonce, jwksUrl: TestConstants.validJwksUrl, config: TestConstants.validTestConfig, error: &error)
        XCTAssertEqual(result, false)
        XCTAssertEqual(error, APIError.failedToUnwrapIdTokenString as NSError)
    }

    func testIdTokenParseHeaderFailure() {
        validationManager = ValidationManager(jwksUrlDataManager: StubJwksUrlDataManagerValidData())
        var error: NSError?
        let result = validationManager?.validate(idTokenString: IdTokenData.createInvalidIdTokenString(shouldHaveValidHeader: false, shouldHaveValidPayload: true), authorizationCode: "", clientId: TestConstants.testClientId, nonce: TestConstants.testNonce, jwksUrl: TestConstants.validJwksUrl, config: TestConstants.validTestConfig, error: &error)
        XCTAssertEqual(result, false)
        XCTAssertEqual(error, APIError.failedToParseIdTokenHeader as NSError)
    }

    func testIdTokenParsePayloadFailure() {
        validationManager = ValidationManager(jwksUrlDataManager: StubJwksUrlDataManagerValidData())
        var error: NSError?
        let result = validationManager?.validate(idTokenString: IdTokenData.createInvalidIdTokenString(shouldHaveValidHeader: true, shouldHaveValidPayload: false), authorizationCode: "", clientId: TestConstants.testClientId, nonce: TestConstants.testNonce, jwksUrl: TestConstants.validJwksUrl, config: TestConstants.validTestConfig, error: &error)
        XCTAssertEqual(result, false)
        XCTAssertEqual(error, APIError.failedToParseIdTokenPayload as NSError)
    }
    
    func testJwksUrlDataIsNil() {
        validationManager = ValidationManager(jwksUrlDataManager: StubJwksUrlDataManagerNilData())
        var error: NSError?
        let result = validationManager?.validate(idTokenString: IdTokenData.createValidIdTokenString(), authorizationCode: "", clientId: TestConstants.testClientId, nonce: TestConstants.testNonce, jwksUrl: TestConstants.validJwksUrl, config: TestConstants.validTestConfig, error: &error)
        XCTAssertEqual(result, false)
    }
    
    func testIdTokenHeaderValidationFailure() {
        validationManager = ValidationManager(jwksUrlDataManager: StubJwksUrlDataManagerInvalidData())
        var error: NSError?
        let result = validationManager?.validate(idTokenString: IdTokenData.createValidIdTokenString(), authorizationCode: "", clientId: TestConstants.testClientId, nonce: TestConstants.testNonce, jwksUrl: TestConstants.validJwksUrl, config: TestConstants.validTestConfig, error: &error)
        XCTAssertEqual(result, false)
        XCTAssertEqual(error, APIError.keyIdsAreDifferentError as NSError)
    }
    
    func testIdTokenPayloadValidationFailureWrongClientId() {
        validationManager = ValidationManager(jwksUrlDataManager: StubJwksUrlDataManagerValidData())
        var error: NSError?
        let result = validationManager?.validate(idTokenString: IdTokenData.createValidIdTokenString(), authorizationCode: "", clientId: TestConstants.wrongClientId, nonce: TestConstants.wrongNonce, jwksUrl: TestConstants.validJwksUrl, config: TestConstants.validTestConfig, error: &error)
        XCTAssertEqual(result, false)
        XCTAssertEqual(error, APIError.failedToValidateIdTokenPayload as NSError)
    }
    
    func testIdTokenPayloadValidationFailureWrongExpDate() {
        validationManager = ValidationManager(jwksUrlDataManager: StubJwksUrlDataManagerValidData())
        var error: NSError?
        let result = validationManager?.validate(idTokenString: IdTokenData.createIdTokenWithInvalidExpDateInPayload(), authorizationCode: "", clientId: TestConstants.testClientId, nonce: TestConstants.testNonce, jwksUrl: TestConstants.validJwksUrl, config: TestConstants.validTestConfig, error: &error)
        XCTAssertEqual(result, false)
        XCTAssertEqual(error, APIError.failedToValidateIdTokenPayload as NSError)
    }
    
    func testPublicKeyCreationFailure() {
        validationManager = ValidationManager(jwksUrlDataManager: StubJwksUrlDataManagerValidData(), publicKeyCreator: StubPublicKeyCreateInvalid())
        var error: NSError?
        let result = validationManager?.validate(idTokenString: IdTokenData.createValidIdTokenString(), authorizationCode: "", clientId: TestConstants.testClientId, nonce: TestConstants.testNonce, jwksUrl: TestConstants.validJwksUrl, config: TestConstants.validTestConfig, error: &error)
        XCTAssertEqual(result, false)
        XCTAssertEqual(error, APIError.failedToCreatePublicKey as NSError)
    }
    
    func testWrongAuthCodeValidationFailure() {
        validationManager = ValidationManager(jwksUrlDataManager: StubJwksUrlDataManagerValidData())
        var error: NSError?
        let result = validationManager?.validate(idTokenString: IdTokenData.createValidIdTokenString(), authorizationCode: "", clientId: TestConstants.testClientId, nonce: TestConstants.testNonce, jwksUrl: TestConstants.validJwksUrl, config: TestConstants.validTestConfig, error: &error)
        XCTAssertEqual(result, false)
        XCTAssertEqual(error, APIError.failedToValidateAuthCode as NSError)
    }
}
