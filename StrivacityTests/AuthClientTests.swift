//
//  AuthClientTests.swift
//  StrivacityTests
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation
import AppAuth
import XCTest
@testable import Strivacity

class AuthClientTests: XCTestCase {
    let viewController = UIViewController()
    var authClient: IAuthClient?
    
    override func tearDown() {
        authClient = nil
    }
    
    // MARK: - Auth code flow
    func testAuthCodeFlowWrongDomain() {
        authClient = AuthClient(config: TestConstants.wrongDomainConfig, authState: nil, secureStorage: SecureStorage())
        authClient?.authorizeAuthCodeFlow(viewController: viewController) { result in
            switch result {
            case .failure(let error):
                XCTAssertEqual(error as NSError, APIError.failedToCreateDomainUrlFromConfig as NSError)
                break
            case .success(_):
                break
            }
        }
    }
    
    func testAuthCodeFlowFailedToDiscoverConfig() {
        authClient = AuthClient(config: TestConstants.validTestConfig, authState: nil, secureStorage: SecureStorage(), authServiceProvider: StubAuthServiceProviderWrongConfiguration())
        authClient?.authorizeAuthCodeFlow(viewController: viewController) { result in
            switch result {
            case .failure(let error):
                XCTAssertEqual(error as NSError, APIError.failedToDiscoverConfiguration as NSError)
                break
            case .success(_):
                break
            }
        }
    }
    
    func testAuthCodeFlowWrongRedirectUri() {
        authClient = AuthClient(config: TestConstants.wrongRedirectUriConfig, authState: nil, secureStorage: SecureStorage(), authServiceProvider: StubAuthServiceProviderValid())
        authClient?.authorizeAuthCodeFlow(viewController: viewController) { result in
            switch result {
            case .failure(let error):
                XCTAssertEqual(error as NSError, APIError.failedToObtainRedirectUri as NSError)
                break
            case .success(_):
                break
            }
        }
    }
    
    func testAuthCodeFlowFailedToGetAuthResponse() {
        authClient = AuthClient(config: TestConstants.validTestConfig, authState: nil, secureStorage: SecureStorage(), authServiceProvider: StubAuthServiceProviderWrongRequestsResults())
        authClient?.authorizeAuthCodeFlow(viewController: viewController) { result in
            switch result {
            case .failure(let error):
                XCTAssertNotNil(error)
                break
            case .success(_):
                break
            }
        }
    }
    
    func testAuthCodeFlowSucceeded() {
        authClient = AuthClient(config: TestConstants.validTestConfig, authState: nil, secureStorage: SecureStorage(), authServiceProvider: StubAuthServiceProviderValid())
        authClient?.authorizeAuthCodeFlow(viewController: viewController) { result in
            switch result {
            case .failure(_):
                break
            case .success(let authState):
                XCTAssertNotNil(authState)
                break
            }
        }
    }
    
    
    // MARK: - Hybrid code flow
    func testHybridAuthFlowWrongDomain() {
        authClient = AuthClient(config: TestConstants.wrongDomainConfig, authState: nil, secureStorage: SecureStorage())
        authClient?.authorizeHybridFlow(viewController: viewController) { result in
            switch result {
            case .failure(let error):
                XCTAssertEqual(error as NSError, APIError.failedToCreateDomainUrlFromConfig as NSError)
                break
            case .success(_):
                break
            }
        }
    }
    
    func testHybridAuthFlowNilResponseUrl() {
        authClient = AuthClient(config: TestConstants.validTestConfig, authState: nil, secureStorage: SecureStorage(), authServiceProvider: StubAuthServiceProviderWrongRequestsResults())
        authClient?.authorizeHybridFlow(viewController: viewController) { result in
            switch result {
            case .failure(let error):
                XCTAssertNotNil(error)
                break
            case .success(_):
                break
            }
        }
    }
    
    func testHybridAuthFlowStateMismatch() {
        authClient = AuthClient(config: TestConstants.validTestConfig, authState: nil, secureStorage: SecureStorage(), authServiceProvider: StubAuthServiceProviderHybridFlowStateMismatch())
        authClient?.authorizeHybridFlow(viewController: viewController) { result in
            switch result {
            case .failure(let error):
                XCTAssertNotNil(error)
                break
            case .success(_):
                break
            }
        }
    }
    
    func testHybridAuthFlowWrongJwksUrl() {
        authClient = AuthClient(config: TestConstants.validTestConfig, authState: nil, secureStorage: SecureStorage(), authServiceProvider: StubAuthServiceProviderValid())
        authClient?.authorizeHybridFlow(viewController: viewController) { result in
            switch result {
            case .failure(let error):
                XCTAssertEqual(APIError.failedToUnwrapJwksUrl as NSError, error as NSError)
                break
            case .success(_):
                break
            }
        }
    }
    
    func testHybridFlowAuthorizationError() {
        authClient = AuthClient(config: TestConstants.validTestConfig, authState: nil, secureStorage: SecureStorage(), authServiceProvider: StubAuthServiceProviderHybridFlowErrorInUrl())
        authClient?.authorizeHybridFlow(viewController: viewController) { result in
            switch result {
            case .failure(let error):
                XCTAssertNotNil(error)
                XCTAssertEqual(error._domain, OIDOAuthAuthorizationErrorDomain)
                break
            case .success(_):
                break
            }
        }
    }
    
    
    // MARK: - Request id token flow
    func testRequestIdTokenFlowInvalidTokenExchangeRequest() {
        authClient = AuthClient(config: TestConstants.validTestConfig, authState: nil, secureStorage: SecureStorage())
        authClient?.requestIdToken() { result in
            switch result {
            case .failure(let error):
                XCTAssertEqual(error as NSError, APIError.failedToObtainTokenExchangeRequestFromLastAuthorizationResponse as NSError)
                break
            case .success(_):
                break
            }
        }
    }
    
    func testRequestIdTokenInvalidResponse() {
        authClient = AuthClient(config: TestConstants.validTestConfig, authState: nil, secureStorage: SecureStorage(), authServiceProvider: StubAuthServiceProviderWrongRequestsResults(), authStateProvider: StubAuthStateProviderValidData())
        authClient?.requestIdToken() { result in
            switch result {
            case .failure(let error):
                XCTAssertEqual(error as NSError, APIError.unexpectedError as NSError)
                break
            case .success(_):
                break
            }
        }
    }
    
    func testRequestIdTokenSuccess() {
        authClient = AuthClient(config: TestConstants.validTestConfig, authState: nil, secureStorage: SecureStorage(), authServiceProvider: StubAuthServiceProviderValid(), authStateProvider: StubAuthStateProviderValidData())
        authClient?.requestIdToken() { result in
            switch result {
            case .failure(_):
                break
            case .success(let authState):
                XCTAssertNotNil(authState)
                break
            }
        }
    }
    
   
    // MARK: - Request access token flow
    func testRequestAccessTokenNilTokenResponse() {
        authClient = AuthClient(config: TestConstants.validTestConfig, authState: nil, secureStorage: SecureStorage(), authServiceProvider: StubAuthServiceProviderWrongRequestsResults())
        authClient?.requestAccessToken(viewController: viewController) { result in
            switch result {
            case .failure(let error):
                XCTAssertNotNil(error)
                break
            case .success(_):
                break
            }
        }
    }
    
    func testRequestAccessTokenSuccess() {
        authClient = AuthClient(config: TestConstants.validTestConfig, authState: nil, secureStorage: SecureStorage(), authServiceProvider: StubAuthServiceProviderValidForAccessToken())
        authClient?.requestAccessToken(viewController: viewController) { result in
            switch result {
            case .failure(_):
                break
            case .success(let authState):
                XCTAssertNotNil(authState)
                break
            }
        }
    }
    
    // MARK: - Logout flow
    func testLogoutWrongIdToken() {
        authClient = AuthClient(config: TestConstants.validTestConfig, authState: nil, secureStorage: SecureStorage())
        authClient?.logout(viewController: viewController) { result in
            switch result {
            case .failure(let error):
                XCTAssertEqual(error as NSError, APIError.failedToObtainLogoutComponents as NSError)
                break
            case .success(_):
                break
            }
        }
    }
    
    func testLogoutWrongRedirectUrl() {
        authClient = AuthClient(config: TestConstants.wrongRedirectUriConfig, authState: nil, secureStorage: SecureStorage(), authServiceProvider: StubAuthServiceProviderValid(), authStateProvider: StubAuthStateProviderValidData())
        authClient?.logout(viewController: viewController) { result in
            switch result {
            case .failure(let error):
                XCTAssertEqual(error as NSError, APIError.failedToObtainRedirectUri as NSError)
                break
            case .success(_):
                break
            }
        }
    }
    
    func testLogoutEndSessionFailure() {
        authClient = AuthClient(config: TestConstants.validTestConfig, authState: nil, secureStorage: SecureStorage(), authServiceProvider: StubAuthServiceProviderWrongRequestsResults(), authStateProvider: StubAuthStateProviderValidData())
        authClient?.logout(viewController: viewController) { result in
            switch result {
            case .failure(_):
                break
            case .success(let result):
                XCTAssertEqual(result, true)
                break
            }
        }
    }
    
    
    // MARK: - Comparing
    func testCompareEqualAuthClients() {
        let firstAuthClient = AuthClient(config: TestConstants.validTestConfig, authState: nil, secureStorage: SecureStorage())
        let secondAuthClient = AuthClient(config: TestConstants.validTestConfig, authState: nil, secureStorage: SecureStorage())
        XCTAssertEqual(firstAuthClient, secondAuthClient)
    }
    
    func testCompareNotEqualAuthClients() {
        let firstAuthClient = AuthClient(config: TestConstants.wrongDomainConfig, authState: nil, secureStorage: SecureStorage())
        let secondAuthClient = AuthClient(config: TestConstants.validTestConfig, authState: nil, secureStorage: SecureStorage())
        XCTAssertNotEqual(firstAuthClient, secondAuthClient)
    }
    
    // MARK: - Auth client creation
    func testAuthClientCreationWithAuthState() {
        authClient = AuthClient(config: TestConstants.validTestConfig, authState: AuthClientData.createAuthState(), secureStorage: SecureStorage())
        XCTAssertNotNil(authClient?.getAuthState())
    }
    
    // MARK: - Other
    func testProceedExternalUserAgentFlowWrongCurrentAuthFlow() {
        authClient = AuthClient(config: TestConstants.validTestConfig, authState: nil, secureStorage: nil)
        let result = authClient?.proceedExternalUserAgentFlow(with: URL(string: TestConstants.validTestConfig.domain)!)
        XCTAssertEqual(result, false)
    }
    
    
}
