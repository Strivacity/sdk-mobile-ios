//
//  AuthServiceProviderStubs.swift
//  StrivacityTests
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation
import AppAuth
import XCTest
@testable import Strivacity

class StubAuthServiceProviderWrongConfiguration: IAuthServiceProvider {
    func discoverServiceConfig(for url: URL) -> (OIDServiceConfiguration?, NSError?) {
        return (nil, APIError.failedToDiscoverConfiguration as NSError)
    }
    
    func presentAuthRequest(_ request: OIDAuthorizationRequest, viewController: UIViewController) -> (OIDExternalUserAgentSession?, OIDAuthorizationResponse?, NSError?) {
        return (nil, nil, nil)
    }
    
    func presentHybridFlowRequest(_ requestUrl: URL, scheme: String?, userAgent: OIDExternalUserAgentIOS) -> (URL?, NSError?) {
        return (nil, nil)
    }
    
    func performTokenRequest(_ request: OIDTokenRequest) -> (OIDTokenResponse?, NSError?) {
        return (nil, nil)
    }
    
    func presentEndSessionRequest(_ request: OIDEndSessionRequest, externalUserAgent: OIDExternalUserAgent) -> (OIDEndSessionResponse?, OIDExternalUserAgentSession?, NSError?) {
        return (nil, nil, nil)
    }
}

class StubAuthServiceProviderWrongRequestsResults: IAuthServiceProvider {
    func discoverServiceConfig(for url: URL) -> (OIDServiceConfiguration?, NSError?) {
        return (AuthClientData.createValidServiceConfiguration(), nil)
    }
    
    func presentAuthRequest(_ request: OIDAuthorizationRequest, viewController: UIViewController) -> (OIDExternalUserAgentSession?, OIDAuthorizationResponse?, NSError?) {
        return (nil, nil, APIError.unexpectedError as NSError)
    }
    
    func presentHybridFlowRequest(_ requestUrl: URL, scheme: String?, userAgent: OIDExternalUserAgentIOS) -> (URL?, NSError?) {
        return (nil, APIError.unexpectedError as NSError)
    }
    
    func performTokenRequest(_ request: OIDTokenRequest) -> (OIDTokenResponse?, NSError?) {
        return (nil, APIError.unexpectedError as NSError)
    }
    
    func presentEndSessionRequest(_ request: OIDEndSessionRequest, externalUserAgent: OIDExternalUserAgent) -> (OIDEndSessionResponse?, OIDExternalUserAgentSession?, NSError?) {
        return (nil, nil, APIError.unexpectedError as NSError)
    }
}

class StubAuthServiceProviderValid: IAuthServiceProvider {
    func discoverServiceConfig(for url: URL) -> (OIDServiceConfiguration?, NSError?) {
        return (AuthClientData.createValidServiceConfiguration(), nil)
    }
    
    func presentAuthRequest(_ request: OIDAuthorizationRequest, viewController: UIViewController) -> (OIDExternalUserAgentSession?, OIDAuthorizationResponse?, NSError?) {
        let (session, response) = AuthClientData.createAuthRequestResults()
        return (session, response, nil)
    }
    
    func presentHybridFlowRequest(_ requestUrl: URL, scheme: String?, userAgent: OIDExternalUserAgentIOS) -> (URL?, NSError?) {
        if let components = URLComponents(url: requestUrl, resolvingAgainstBaseURL: false) {
            let state = components.queryItems?.first(where: { $0.name == "state" })?.value ?? ""
            let url = URL(string: TestConstants.hybridFlowResponsePart + IdTokenData.createValidIdTokenString() + "&state=" + state)
            return (url, nil)
        }
        
        return (nil, nil)
    }
    
    func performTokenRequest(_ request: OIDTokenRequest) -> (OIDTokenResponse?, NSError?) {
        return (AuthClientData.createTokenResponseForIdTokenRequest(), nil)
    }
    
    func presentEndSessionRequest(_ request: OIDEndSessionRequest, externalUserAgent: OIDExternalUserAgent) -> (OIDEndSessionResponse?, OIDExternalUserAgentSession?, NSError?) {
        return (nil, nil, nil)
    }
}


class StubAuthServiceProviderValidForAccessToken: IAuthServiceProvider {
    func discoverServiceConfig(for url: URL) -> (OIDServiceConfiguration?, NSError?) {
        return (AuthClientData.createValidServiceConfiguration(), nil)
    }
    
    func presentAuthRequest(_ request: OIDAuthorizationRequest, viewController: UIViewController) -> (OIDExternalUserAgentSession?, OIDAuthorizationResponse?, NSError?) {
        let (session, response) = AuthClientData.createAuthRequestResults()
        return (session, response, nil)
    }
    
    func presentHybridFlowRequest(_ requestUrl: URL, scheme: String?, userAgent: OIDExternalUserAgentIOS) -> (URL?, NSError?) {
        let url = URL(string: TestConstants.hybridFlowResponsePart + IdTokenData.createValidIdTokenString())
        return (url, nil)
    }
    
    func performTokenRequest(_ request: OIDTokenRequest) -> (OIDTokenResponse?, NSError?) {
        return (AuthClientData.createTokenResponseForAccessTokenRequest(), nil)
    }
    
    func presentEndSessionRequest(_ request: OIDEndSessionRequest, externalUserAgent: OIDExternalUserAgent) -> (OIDEndSessionResponse?, OIDExternalUserAgentSession?, NSError?) {
        return (nil, nil, nil)
    }
}


class StubAuthServiceProviderHybridFlowStateMismatch: IAuthServiceProvider {
    func discoverServiceConfig(for url: URL) -> (OIDServiceConfiguration?, NSError?) {
        return (AuthClientData.createValidServiceConfiguration(), nil)
    }
    
    func presentAuthRequest(_ request: OIDAuthorizationRequest, viewController: UIViewController) -> (OIDExternalUserAgentSession?, OIDAuthorizationResponse?, NSError?) {
        let (session, response) = AuthClientData.createAuthRequestResults()
        return (session, response, nil)
    }
    
    func presentHybridFlowRequest(_ requestUrl: URL, scheme: String?, userAgent: OIDExternalUserAgentIOS) -> (URL?, NSError?) {
        let url = URL(string: TestConstants.hybridFlowResponsePart + IdTokenData.createValidIdTokenString())
        return (url, nil)
    }
    
    func performTokenRequest(_ request: OIDTokenRequest) -> (OIDTokenResponse?, NSError?) {
        return (AuthClientData.createTokenResponseForIdTokenRequest(), nil)
    }
    
    func presentEndSessionRequest(_ request: OIDEndSessionRequest, externalUserAgent: OIDExternalUserAgent) -> (OIDEndSessionResponse?, OIDExternalUserAgentSession?, NSError?) {
        return (nil, nil, nil)
    }
}


class StubAuthServiceProviderHybridFlowErrorInUrl: IAuthServiceProvider {
    func discoverServiceConfig(for url: URL) -> (OIDServiceConfiguration?, NSError?) {
        return (AuthClientData.createValidServiceConfiguration(), nil)
    }
    
    func presentAuthRequest(_ request: OIDAuthorizationRequest, viewController: UIViewController) -> (OIDExternalUserAgentSession?, OIDAuthorizationResponse?, NSError?) {
        let (session, response) = AuthClientData.createAuthRequestResults()
        return (session, response, nil)
    }
    
    func presentHybridFlowRequest(_ requestUrl: URL, scheme: String?, userAgent: OIDExternalUserAgentIOS) -> (URL?, NSError?) {
        let url = URL(string: TestConstants.hybridFlowResponsePart + IdTokenData.createValidIdTokenString() + "&error=test_error")
        return (url, nil)
    }
    
    func performTokenRequest(_ request: OIDTokenRequest) -> (OIDTokenResponse?, NSError?) {
        return (AuthClientData.createTokenResponseForIdTokenRequest(), nil)
    }
    
    func presentEndSessionRequest(_ request: OIDEndSessionRequest, externalUserAgent: OIDExternalUserAgent) -> (OIDEndSessionResponse?, OIDExternalUserAgentSession?, NSError?) {
        return (nil, nil, nil)
    }
}
