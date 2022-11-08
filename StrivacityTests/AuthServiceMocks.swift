//
//  AuthServiceMocks.swift
//  StrivacityTests
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation
import AppAuth
import XCTest
@testable import Strivacity

class MockAuthServiceInvalidResults: IAuthService {
    func discoverServiceConfig(for url: URL, callback: @escaping (OIDServiceConfiguration?, Error?) -> Void) {
        callback(nil, APIError.unexpectedError)
    }
    
    func presentAuthRequest(_ request: OIDAuthorizationRequest, viewController: UIViewController, callback: @escaping (OIDAuthorizationResponse?, Error?) -> Void) -> OIDExternalUserAgentSession? {
        callback(nil, APIError.unexpectedError)
        return nil
    }
    
    func presentHybridFlowRequest(_ requestUrl: URL, scheme: String?, userAgent: OIDExternalUserAgentIOS, callback: @escaping (URL?, Error?) -> Void) {
        callback(nil, APIError.unexpectedError)
    }
    
    func performTokenRequest(_ request: OIDTokenRequest, callback: @escaping (OIDTokenResponse?, Error?) -> Void) {
        callback(nil, APIError.unexpectedError)
    }
    
    func presentEndSessionRequest(_ request: OIDEndSessionRequest, externalUserAgent: OIDExternalUserAgent, callback: @escaping (OIDEndSessionResponse?, Error?) -> Void) -> OIDExternalUserAgentSession? {
        callback(nil, APIError.unexpectedError)
        return nil
    }
}

class MockAuthServiceValidResults: IAuthService {
    func discoverServiceConfig(for url: URL, callback: @escaping (OIDServiceConfiguration?, Error?) -> Void) {
        callback(AuthClientData.createValidServiceConfiguration(), nil)
    }
    
    func presentAuthRequest(_ request: OIDAuthorizationRequest, viewController: UIViewController, callback: @escaping (OIDAuthorizationResponse?, Error?) -> Void) -> OIDExternalUserAgentSession? {
        let (userAgentSession, authResponse) = AuthClientData.createAuthRequestResults()
        callback(authResponse, nil)
        return userAgentSession
    }
    
    func presentHybridFlowRequest(_ requestUrl: URL, scheme: String?, userAgent: OIDExternalUserAgentIOS, callback: @escaping (URL?, Error?) -> Void) {
        callback(URL(string: TestConstants.hybridFlowResponsePart + IdTokenData.createValidIdTokenString())!, nil)
    }
    
    func performTokenRequest(_ request: OIDTokenRequest, callback: @escaping (OIDTokenResponse?, Error?) -> Void) {
        callback(AuthClientData.createTokenResponseForIdTokenRequest(), nil)
    }
    
    func presentEndSessionRequest(_ request: OIDEndSessionRequest, externalUserAgent: OIDExternalUserAgent, callback: @escaping (OIDEndSessionResponse?, Error?) -> Void) -> OIDExternalUserAgentSession? {
        callback(AuthClientData.createEndSessionResponse(), nil)
        return NSObject() as? OIDExternalUserAgentSession
    }
}
