//
//  AuthServiceProviderTests.swift
//  StrivacityTests
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation
import AppAuth
import XCTest
@testable import Strivacity

class AuthServiceProviderTests: XCTestCase {
    var authServiceProvider: IAuthServiceProvider?
    
    override func tearDown() {
        authServiceProvider = nil
    }
    
    func testDiscoverServiceConfigFailure() {
        authServiceProvider = AuthServiceProvider(MockAuthServiceInvalidResults())
        let result = authServiceProvider?.discoverServiceConfig(for: URL(string: TestConstants.testDomain)!)
        
        XCTAssertNil(result?.0)
        XCTAssertNotNil(result?.1)
    }

    func testDiscoverServiceConfigSuccess() {
        authServiceProvider = AuthServiceProvider(MockAuthServiceValidResults())
        let result = authServiceProvider?.discoverServiceConfig(for: URL(string: TestConstants.testDomain)!)
        
        XCTAssertNotNil(result?.0)
        XCTAssertNil(result?.1)
    }
    
    func testPresentAuthRequestFailure() {
        authServiceProvider = AuthServiceProvider(MockAuthServiceInvalidResults())
        let result = authServiceProvider?.presentAuthRequest(AuthClientData.createAuthRequest(), viewController: UIViewController())
        
        XCTAssertNil(result?.0)
        XCTAssertNil(result?.1)
        XCTAssertNotNil(result?.2)
    }
    
    func testPresentAuthRequestSuccess() {
        authServiceProvider = AuthServiceProvider(MockAuthServiceValidResults())
        let result = authServiceProvider?.presentAuthRequest(AuthClientData.createAuthRequest(), viewController: UIViewController())
        
        XCTAssertNotNil(result?.0)
        XCTAssertNotNil(result?.1)
        XCTAssertNil(result?.2)
    }
    
    func testHybridFlowRequestFailure() {
        authServiceProvider = AuthServiceProvider(MockAuthServiceInvalidResults())
        let result = authServiceProvider?.presentHybridFlowRequest(URL(string: TestConstants.hybridFlowResponsePart + IdTokenData.createValidIdTokenString())!, scheme: TestConstants.httpsScheme, userAgent: OIDExternalUserAgentIOS(presenting: UIViewController())!)
        
        XCTAssertNil(result?.0)
        XCTAssertNotNil(result?.1)
    }
    
    func testHybridFlowRequestSuccess() {
        authServiceProvider = AuthServiceProvider(MockAuthServiceValidResults())
        let result = authServiceProvider?.presentHybridFlowRequest(URL(string: TestConstants.hybridFlowResponsePart + IdTokenData.createValidIdTokenString())!, scheme: TestConstants.httpsScheme, userAgent: OIDExternalUserAgentIOS(presenting: UIViewController())!)
        
        XCTAssertNotNil(result?.0)
        XCTAssertNil(result?.1)
    }
    
    func testPerformTokenRequestFailure() {
        authServiceProvider = AuthServiceProvider(MockAuthServiceInvalidResults())
        let result = authServiceProvider?.performTokenRequest(AuthClientData.createTokenRequest()!)
        
        XCTAssertNil(result?.0)
        XCTAssertNotNil(result?.1)
    }
    
    func testPerformTokenRequestSuccess() {
        authServiceProvider = AuthServiceProvider(MockAuthServiceValidResults())
        let result = authServiceProvider?.performTokenRequest(AuthClientData.createTokenRequest()!)
        
        XCTAssertNotNil(result?.0)
        XCTAssertNil(result?.1)
    }
    
    func testEndSessionRequestFailure() {
        authServiceProvider = AuthServiceProvider(MockAuthServiceInvalidResults())
        let result = authServiceProvider?.presentEndSessionRequest(AuthClientData.createEndSessionRequest(), externalUserAgent: OIDExternalUserAgentIOS(presenting: UIViewController())!)
        
        XCTAssertNil(result?.0)
        XCTAssertNil(result?.1)
        XCTAssertNotNil(result?.2)
    }
    
    func testEndSessionRequestSuccess() {
        authServiceProvider = AuthServiceProvider(MockAuthServiceValidResults())
        let result = authServiceProvider?.presentEndSessionRequest(AuthClientData.createEndSessionRequest(), externalUserAgent: OIDExternalUserAgentIOS(presenting: UIViewController())!)
        
        XCTAssertNotNil(result?.0)
        XCTAssertNil(result?.2)
    }
}
