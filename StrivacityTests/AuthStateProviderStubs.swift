//
//  AuthStateProviderStubs.swift
//  StrivacityTests
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation
import AppAuth
import XCTest
@testable import Strivacity

class StubAuthStateProviderValidData: IAuthStateProvider {
    private var authState: OIDAuthState?
    
    func setAuthState(_ state: OIDAuthState?) {
        authState = state != nil ? state : AuthClientData.createAuthState()
    }
    
    func setAuthState(_ authResponse: OIDAuthorizationResponse) {
        authState = OIDAuthState.init(authorizationResponse: authResponse)
    }
    
    func setAuthState(_ authResponse: OIDAuthorizationResponse, tokenResponse: OIDTokenResponse?) {
        authState = OIDAuthState.init(authorizationResponse: authResponse, tokenResponse: tokenResponse)
    }
    
    func getTokenExchangeRequest() -> OIDTokenRequest? {
        AuthClientData.createTokenRequest()
    }
    
    func update(_ tokenResponse: OIDTokenResponse?, error: NSError?) {
        authState?.update(with: tokenResponse, error: error)
    }
    
    func getAuthState() -> AnyObject? {
        authState
    }
    
    func getIdToken() -> String? {
        IdTokenData.createValidIdTokenString()
    }
}
