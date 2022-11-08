//
//  AuthProviderTests.swift
//  StrivacityTests
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation
import AppAuth
import XCTest
@testable import Strivacity

final class AuthProviderTests: XCTestCase, IProviderCallback {
    var successExpectation: XCTestExpectation?
    var failureExpectation: XCTestExpectation?
    var actualError: NSError?
    var actualAuthClient: AuthClient?
    var secureStorage: ISecureStorage?
    
    override func tearDown() {
        successExpectation = nil
        failureExpectation = nil
        actualError = nil
        actualAuthClient = nil
        secureStorage = nil
    }
    
    func onSuccess(authClient: AuthClient) {
        successExpectation?.fulfill()
        XCTAssertEqual(authClient, actualAuthClient)
    }
    
    func onError(error: NSError) {
        failureExpectation?.fulfill()
        XCTAssertEqual(error, actualError)
    }
    
    func testAuthProviderInitWithSecureStorageAndBiometricAuthenticationSucceeded() {
        successExpectation = self.expectation(description: "AuthProvider init")
        secureStorage = SecureStorage()
        actualAuthClient = AuthClient(config: TestConstants.validTestConfig, authState: nil, secureStorage: secureStorage)
        let authProvider = AuthProvider()
            .withClientId(TestConstants.testClientId)
            .withClientSecret(TestConstants.testClientSecret)
            .withDomain(TestConstants.testDomain)
            .withRedirectUri(TestConstants.testRedirectUri)
            .setUseSecureStorage(true)
            .setUseBiometric(.any, BiometricManager(context: StubLAContextBiometricEnabledAndSucceded()))
        authProvider.provide(self)
        
        self.waitForExpectations(timeout: 10)
    }
    
    func testAuthProviderInitWithSecureStorageAndBiometricAuthenticationFailed() {
        failureExpectation = self.expectation(description: "AuthProvider init")
        actualError = APIError.biometricAuthenticationError as NSError
        secureStorage = SecureStorage()
        let authProvider = AuthProvider()
            .withClientId(TestConstants.testClientId)
            .withClientSecret(TestConstants.testClientSecret)
            .withDomain(TestConstants.testDomain)
            .withRedirectUri(TestConstants.testRedirectUri)
            .setUseSecureStorage(true)
            .setUseBiometric(.any, BiometricManager(context: StubLAContextBiometricEnabledAndFailed()))
        authProvider.provide(self)
        
        self.waitForExpectations(timeout: 10)
    }
    
    func testAuthProviderInitWithoutSecureStorageAndBiometric() {
        successExpectation = self.expectation(description: "AuthProvider init")
        actualAuthClient = AuthClient(config: TestConstants.validTestConfig, authState: nil, secureStorage: nil)
        let authProvider = AuthProvider()
            .withClientId(TestConstants.testClientId)
            .withClientSecret(TestConstants.testClientSecret)
            .withDomain(TestConstants.testDomain)
            .withRedirectUri(TestConstants.testRedirectUri)
            .setUseSecureStorage(false)
            .setUseBiometric(.none)
        authProvider.provide(self)
        
        self.waitForExpectations(timeout: 10)
    }
    
    func testAuthProviderInitWithBiometricTurnedOnButDisabled() {
        failureExpectation = self.expectation(description: "AuthProvider init")
        actualError = APIError.biometricIsNotSupportedError as NSError
        let authProvider = AuthProvider()
            .withClientId(TestConstants.testClientId)
            .withClientSecret(TestConstants.testClientSecret)
            .withDomain(TestConstants.testDomain)
            .withRedirectUri(TestConstants.testRedirectUri)
            .setUseSecureStorage(false)
            .setUseBiometric(.any, BiometricManager(context: StubLAContextBiometricDisabled()))
        authProvider.provide(self)

        self.waitForExpectations(timeout: 10)
    }
    
    func testAuthProviderBiometricIsSupported() {
        let authProvider = AuthProvider()
            .withClientId(TestConstants.testClientId)
            .withClientSecret(TestConstants.testClientSecret)
            .withDomain(TestConstants.testDomain)
            .withRedirectUri(TestConstants.testRedirectUri)
            .setUseSecureStorage(true)
            .setUseBiometric(.any, BiometricManager(context: StubLAContextBiometricEnabledAndSucceded()))
        let result = authProvider.isBiometricSupported()
        XCTAssertEqual(result, true)
    }
    
    func testAuthProviderBiometricIsNotSupported() {
        let authProvider = AuthProvider()
            .withClientId(TestConstants.testClientId)
            .withClientSecret(TestConstants.testClientSecret)
            .withDomain(TestConstants.testDomain)
            .withRedirectUri(TestConstants.testRedirectUri)
            .setUseSecureStorage(true)
            .setUseBiometric(.any, BiometricManager(context: StubLAContextBiometricDisabled()))
        let result = authProvider.isBiometricSupported()
        XCTAssertEqual(result, false)
    }
    
    func testAuthProviderInitWithAuthState() {
        let authState = AuthClientData.createAuthState()
        successExpectation = self.expectation(description: "AuthProvider init")
        secureStorage = SecureStorage()
        actualAuthClient = AuthClient(config: TestConstants.validTestConfig, authState: authState, secureStorage: secureStorage)
        let authProvider = AuthProvider()
            .withClientId(TestConstants.testClientId)
            .withClientSecret(TestConstants.testClientSecret)
            .withDomain(TestConstants.testDomain)
            .withRedirectUri(TestConstants.testRedirectUri)
            .withAuthState(authState)
            .setUseSecureStorage(true)
            .setUseBiometric(.any, BiometricManager(context: StubLAContextBiometricEnabledAndSucceded()))
        authProvider.provide(self)
        
        self.waitForExpectations(timeout: 10)
    }
}
