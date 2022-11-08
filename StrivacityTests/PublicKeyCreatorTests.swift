//
//  PublicKeyCreatorTests.swift
//  StrivacityTests
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation
import XCTest
@testable import Strivacity

final class PublicKeyCreatorTests: XCTestCase {
    var publicKeyCreator: IPublicKeyCreator?
    
    override func setUp() {
        publicKeyCreator = PublicKeyCreator()
    }
    
    override func tearDown() {
        publicKeyCreator = nil
    }
    
    func testPublicKeyCreationSucceeded() {
        let publicKey = publicKeyCreator?.createPublicKey(modulus: TestConstants.testModulus, exponent: "QWER")
        XCTAssertNotEqual(publicKey, nil)
    }
    
    func testPublicKeyCreationSucceededLongModulus() {
        let publicKey = publicKeyCreator?.createPublicKey(modulus: "test_modulustest_modulustest_modulustest_modulustest_modulustest_modulustest_modulustest_modulustest_modulustest_modulustest_modulustest_modulustest_modulustest_modulustest_modulustest_modulustest_modulustest_modulustest_modulustest_modulustest_modulustest_modulustest_modulustest_modulustest_modulustest_modulustest_modulustest_modulustest_modulustest_modulustest_modulustest_modulustest_modulustest_modulustest_modulustest_modulus", exponent: "QWER")
        XCTAssertNotEqual(publicKey, nil)
    }
    
    func testPublicKeyCreationFailed() {
        let publicKey = publicKeyCreator?.createPublicKey(modulus: "", exponent: "QWER")
        XCTAssertEqual(publicKey, nil)
    }
}
