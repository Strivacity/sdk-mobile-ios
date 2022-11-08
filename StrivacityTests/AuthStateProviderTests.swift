//
//  AuthStateProviderTests.swift
//  StrivacityTests
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation
import AppAuth
import XCTest
@testable import Strivacity

class AuthStateProviderTests: XCTestCase {
    var authStateProvider: IAuthStateProvider?
    
    override func setUp() {
        authStateProvider = AuthStateProvider()
    }
    
    override func tearDown() {
        authStateProvider = nil
    }
    
    func testSetAuthState() {
        let authState = AuthClientData.createAuthState()
        authStateProvider?.setAuthState(authState)
        XCTAssertEqual(authState, authStateProvider?.getAuthState() as? OIDAuthState)
    }
    
    func testSetNilAuthState() {
        authStateProvider?.setAuthState(nil)
        XCTAssertNil(authStateProvider?.getAuthState())
    }
    
    func testSetAuthStateWithAuthResponse() {
        let (_, authResponse) = AuthClientData.createAuthRequestResults()
        authStateProvider?.setAuthState(authResponse!)
        XCTAssertNotNil(authStateProvider?.getAuthState())
    }
    
    func testSetAuthStateWithAuthAndTokenResponse() {
        let (_, authResponse) = AuthClientData.createAuthRequestResults()
        let tokenResponse = AuthClientData.createTokenResponseForIdTokenRequest()
        authStateProvider?.setAuthState(authResponse!, tokenResponse: tokenResponse)
        XCTAssertNotNil(authStateProvider?.getAuthState())
    }
    
    func testUpdateAuthState() {
        let (_, authResponse) = AuthClientData.createAuthRequestResults()
        authStateProvider?.setAuthState(authResponse!)
        let tokenResponse = AuthClientData.createTokenResponseForIdTokenRequest()
        authStateProvider?.update(tokenResponse, error: nil)
        
        XCTAssertNotNil(authStateProvider?.getAuthState())
    }
}
