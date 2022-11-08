//
//  AuthClientData.swift
//  StrivacityTests
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation
import AppAuth
import XCTest
@testable import Strivacity

class AuthClientData {
    static func createValidServiceConfiguration() -> OIDServiceConfiguration {
        let authEndpointUrl = URL.init(string: TestConstants.testDomain + Constants.authPart)!
        let tokenEndpointUrl = URL.init(string: TestConstants.testDomain + Constants.endpointTokenPart)!
        let logoutEndpointUrl = URL.init(string: TestConstants.testDomain + Constants.logoutPart)!
        let issuerUrl = URL.init(string: TestConstants.testDomain)
        
        return OIDServiceConfiguration.init(authorizationEndpoint: authEndpointUrl, tokenEndpoint: tokenEndpointUrl, issuer: issuerUrl, registrationEndpoint: nil, endSessionEndpoint: logoutEndpointUrl)
    }
    
    static func createAuthRequest() -> OIDAuthorizationRequest {
        return OIDAuthorizationRequest(configuration: AuthClientData.createValidServiceConfiguration(),
                                              clientId: TestConstants.testClientId,
                                              clientSecret: nil,
                                              scopes: [OIDScopeOpenID, OIDScopeProfile],
                                              redirectURL: URL(string: TestConstants.testRedirectUri)!,
                                              responseType: OIDResponseTypeCode,
                                              additionalParameters: nil)
    }
    
    static func createAuthRequestResults() -> (OIDExternalUserAgentSession?, OIDAuthorizationResponse?) {
        let request = AuthClientData.createAuthRequest()
        let authorizationSession = OIDAuthorizationSession(request: request)
        let response = OIDAuthorizationResponse(request: request, parameters: [:])
        
        return (authorizationSession, response)
    }
    
    static func createTokenRequest() -> OIDTokenRequest? {
        return OIDTokenRequest(
            configuration: AuthClientData.createValidServiceConfiguration(),
            grantType: OIDGrantTypeAuthorizationCode,
            authorizationCode: TestConstants.testAuthCode,
            redirectURL: URL(string: TestConstants.testRedirectUri)!,
            clientID: TestConstants.testClientId,
            clientSecret: TestConstants.testClientSecret,
            scope: nil,
            refreshToken: nil,
            codeVerifier: TestConstants.testCodeVerifier,
            additionalParameters: nil)
    }
    
    static func createTokenResponseForIdTokenRequest() -> OIDTokenResponse? {
        if let tokenRequest = AuthClientData.createTokenRequest() {
            return OIDTokenResponse(request: tokenRequest, parameters: [:])
        }
        
        return nil
    }
    
    static func createTokenResponseForAccessTokenRequest() -> OIDTokenResponse? {
        let tokenRequest = OIDTokenRequest(
            configuration: AuthClientData.createValidServiceConfiguration(),
            grantType: OIDGrantTypeClientCredentials,
            authorizationCode: nil,
            redirectURL: URL(string: TestConstants.testRedirectUri)!,
            clientID: TestConstants.testClientId,
            clientSecret: TestConstants.testClientSecret,
            scope: nil,
            refreshToken: nil,
            codeVerifier: nil,
            additionalParameters: [Constants.audienceKey : TestConstants.testDomainWithHttps])
        
        return OIDTokenResponse(request: tokenRequest, parameters: [:])
    }
    
    class func createAuthState() -> OIDAuthState {
        let kTestAuthEndpoint: URL = URL.init(string: TestConstants.testDomainWithHttps + Constants.authPart)!
        let kTokenEndpoint: URL = URL.init(string: TestConstants.testDomainWithHttps + Constants.endpointTokenPart)!
        
        let config = OIDServiceConfiguration.init(authorizationEndpoint: kTestAuthEndpoint, tokenEndpoint: kTokenEndpoint)
        let authRequest = OIDAuthorizationRequest.init(configuration: config, clientId: TestConstants.testClientId, clientSecret: TestConstants.testClientSecret, scopes: [OIDScopeOpenID, OIDScopeProfile], redirectURL: URL(string: TestConstants.testRedirectUri)!, responseType: OIDResponseTypeCode, additionalParameters: nil)
        
        let authResponse = OIDAuthorizationResponse.init(request: authRequest, parameters: ["code": "Code"] as [String : NSCopying & NSObjectProtocol])
        let authState = OIDAuthState.init(authorizationResponse: authResponse)
        return authState
    }
    
    static func createEndSessionRequest() -> OIDEndSessionRequest {
        return OIDEndSessionRequest(configuration: AuthClientData.createValidServiceConfiguration(), idTokenHint: IdTokenData.createValidIdTokenString(), postLogoutRedirectURL: URL(string: TestConstants.testRedirectUri)!, additionalParameters: nil)
    }
    
    static func createEndSessionResponse() -> OIDEndSessionResponse {
        return OIDEndSessionResponse(request: AuthClientData.createEndSessionRequest(), parameters: [:])
    }
}

