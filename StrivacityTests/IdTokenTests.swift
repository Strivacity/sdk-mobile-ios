//
//  IdTokenTests.swift
//  StrivacityTests
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation
import XCTest
@testable import Strivacity

final class IdTokenTests: XCTestCase {
    var idToken: IdToken?

    override func tearDown() {
        idToken = nil
    }

    func testIsTokenWellFormedSuccess() {
        idToken = IdTokenData.validIdToken
        XCTAssertEqual(idToken?.isWellFormed(), true)
    }

    func testIsTokenWellFormedFailure() {
        idToken = IdTokenData.invalidIdToken
        XCTAssertEqual(idToken?.isWellFormed(), false)
    }

    func testGetValidHeader() {
        idToken = IdTokenData.validIdToken
        XCTAssertEqual(idToken?.getHeader().kidProperty, IdTokenData.validHeader.kidProperty)
        XCTAssertEqual(idToken?.getHeader().algProperty, IdTokenData.validHeader.algProperty)
    }

    func testGetInvalidHeader() {
        idToken = IdTokenData.invalidIdToken
        XCTAssertEqual(idToken?.getHeader().kidProperty, "")
        XCTAssertEqual(idToken?.getHeader().algProperty, "")
    }

    func testGetValidPayload() {
        idToken = IdTokenData.validIdToken
        XCTAssertEqual(idToken?.getPayload(), IdTokenData.validPayload)
    }

    func testGetInvalidPayload() {
        idToken = IdTokenData.invalidIdToken
        let invalidPayload = IdTokenPayload()
        XCTAssertEqual(idToken?.getPayload().sidProperty, invalidPayload.sidProperty)
        XCTAssertEqual(idToken?.getPayload().authTimeProperty, invalidPayload.authTimeProperty)
        XCTAssertEqual(idToken?.getPayload().expProperty, invalidPayload.expProperty)
        XCTAssertEqual(idToken?.getPayload().ratProperty, invalidPayload.ratProperty)
        XCTAssertEqual(idToken?.getPayload().iatProperty, invalidPayload.iatProperty)
        XCTAssertEqual(idToken?.getPayload().clientIdProperty, invalidPayload.clientIdProperty)
        XCTAssertEqual(idToken?.getPayload().userIdProperty, invalidPayload.userIdProperty)
        XCTAssertEqual(idToken?.getPayload().subProperty, invalidPayload.subProperty)
        XCTAssertEqual(idToken?.getPayload().cHashProperty, invalidPayload.cHashProperty)
        XCTAssertEqual(idToken?.getPayload().audProperty, invalidPayload.audProperty)
        XCTAssertEqual(idToken?.getPayload().issProperty, invalidPayload.issProperty)
        XCTAssertEqual(idToken?.getPayload().jtiProperty, invalidPayload.jtiProperty)
        XCTAssertEqual(idToken?.getPayload().nonceProperty, invalidPayload.nonceProperty)
    }

    func testGetValidSignature() {
        idToken = IdTokenData.validIdToken
        XCTAssertEqual(idToken?.getSignature(), IdTokenData.validSignature)
    }

    func testGetInvalidSignature() {
        idToken = IdTokenData.invalidIdToken
        XCTAssertEqual(idToken?.getSignature(), "")
    }
}
