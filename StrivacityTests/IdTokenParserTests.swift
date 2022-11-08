//
//  IdTokenParserTests.swift
//  StrivacityTests
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation
import XCTest
@testable import Strivacity

final class IdTokenParserTests: XCTestCase {
    let idTokenParser: ITokenParser = IdTokenParser()
    
    func testWrongTokenStructure() {
        var error: NSError?
        let idToken = idTokenParser.parse(IdTokenData.invalidIdTokenString, error: &error)
        XCTAssertEqual(error, APIError.wrongTokenStructure as NSError)
        XCTAssertEqual(idToken, nil)
    }
    
    func testParseSuccess() {
        var error: NSError?
        let idToken = idTokenParser.parse(IdTokenData.createValidIdTokenString(), error: &error)
        XCTAssertEqual(error, nil)
        XCTAssertEqual(idToken, IdTokenData.validIdToken)
    }
    
    func testParseWrongHeaderFailure() {
        var error: NSError?
        let idToken = idTokenParser.parse(IdTokenData.createInvalidIdTokenString(shouldHaveValidHeader: false, shouldHaveValidPayload: true), error: &error)
        XCTAssertEqual(error, APIError.failedToParseIdTokenHeader as NSError)
        XCTAssertEqual(idToken, nil)
    }
    
    func testParseEmptyHeaderFailure() {
        var error: NSError?
        let idToken = idTokenParser.parse(IdTokenData.createInvalidIdTokenString(shouldHaveEmptyHeader: true, shouldHaveEmptyPayload: false), error: &error)
        XCTAssertEqual(error, APIError.failedToParseIdTokenHeader as NSError)
        XCTAssertEqual(idToken, nil)
    }
    
    func testParseWrongPayloadFailure() {
        var error: NSError?
        let idToken = idTokenParser.parse(IdTokenData.createInvalidIdTokenString(shouldHaveValidHeader: true, shouldHaveValidPayload: false), error: &error)
        XCTAssertEqual(error, APIError.failedToParseIdTokenPayload as NSError)
        XCTAssertEqual(idToken, nil)
    }
    
    func testParseEmptyPayloadFailure() {
        var error: NSError?
        let idToken = idTokenParser.parse(IdTokenData.createInvalidIdTokenString(shouldHaveEmptyHeader: false, shouldHaveEmptyPayload: true), error: &error)
        XCTAssertEqual(error, APIError.failedToParseIdTokenPayload as NSError)
        XCTAssertEqual(idToken, nil)
    }
}
