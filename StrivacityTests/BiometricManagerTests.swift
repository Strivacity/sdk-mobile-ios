//
//  BiometricManagerTests.swift
//  StrivacityTests
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation
import XCTest
import LocalAuthentication
@testable import Strivacity

final class BiometricManagerTests: XCTestCase {
    
    func testBiometricIsSupported() {
        let biometricManager = BiometricManager(context: StubLAContextBiometricEnabledAndSucceded())
        let result = biometricManager.isBiometricSupported()
        XCTAssertEqual(result, true)
    }
    
    func testBiometricIsNotSupported() {
        let biometricManager = BiometricManager(context: StubLAContextBiometricDisabled())
        let result = biometricManager.isBiometricSupported()
        XCTAssertEqual(result, false)
    }
    
    func testBiometricAuthenticationSuccess() {
        let biometricManager = BiometricManager(context: StubLAContextBiometricEnabledAndSucceded())
        var result: Bool = false
        let expectation = self.expectation(description: "Biometric authentication")
        
        biometricManager.authenticate { authenticationResult in
            expectation.fulfill()
            result = authenticationResult
        }
        
        wait(for: [expectation], timeout: 10)
        XCTAssertEqual(result, true)
    }
    
    func testBiometricAuthenticationFailure() {
        let biometricManager = BiometricManager(context: StubLAContextBiometricEnabledAndFailed())
        var result: Bool = false
        let expectation = self.expectation(description: "Biometric authentication")
        
        biometricManager.authenticate { authenticationResult in
            expectation.fulfill()
            result = authenticationResult
        }
        
        wait(for: [expectation], timeout: 10)
        XCTAssertEqual(result, false)
    }
}
