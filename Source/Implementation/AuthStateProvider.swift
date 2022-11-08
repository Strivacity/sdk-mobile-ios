//
//  AuthState.swift
//  Strivacity
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation
import AppAuth

/**
 * Manages current authorization state which is used inside [AuthClient] object.
 */
class AuthStateProvider: IAuthStateProvider {
    /// represents current authorization state
    private var authState: OIDAuthState?
    
    /**
     * Sets auth state directly using the OIDAuthState object
     *
     * - Parameter state: Authorization state to be set as current
     * the value of the state can be nil, in this case the authorization state is reset
     */
    func setAuthState(_ state: OIDAuthState?) {
        authState = state
    }
    
    /**
     * Sets auth state obtained from the OIDAuthorizationResponse object
     *
     * - Parameter state: OIDAuthorizationResponse with auth state
     */
    func setAuthState(_ authResponse: OIDAuthorizationResponse) {
        authState = OIDAuthState.init(authorizationResponse: authResponse)
    }
    
    /**
     * Sets auth state obtained from the OIDAuthorizationResponse and OIDTokenResponse
     *
     * - Parameters:
     *   - state: Auth response used for auth state creation
     *   - tokenResponse: Token response used for auth state creation
     */
    func setAuthState(_ authResponse: OIDAuthorizationResponse, tokenResponse: OIDTokenResponse?) {
        authState = OIDAuthState.init(authorizationResponse: authResponse, tokenResponse: tokenResponse)
    }
    
    /**
     * Returns token exchange request obtained from current auth state.
     *
     * - Returns: OIDTokenRequest object on success or nil on failure.
     */
    func getTokenExchangeRequest() -> OIDTokenRequest? {
        authState?.lastAuthorizationResponse.tokenExchangeRequest()
    }
    
    /**
     * Performs auth state update using the token response.
     *
     * - Parameters:
     *   - tokenResponse: Token response to update current auth state.
     *   - error: Error which could be occured when token response has been obtained.
     */
    func update(_ tokenResponse: OIDTokenResponse?, error: NSError?) {
        authState?.update(with: tokenResponse, error: error)
    }
    
    /**
     * Provides current auth state.
     *
     * - Returns: auth state
     */
    func getAuthState() -> AnyObject? {
        authState
    }
    
    /**
     * Provides id token string obtained from current auth state or nil if there is no one id token stored.
     *
     * - Returns: id token string
     */
    func getIdToken() -> String? {
        authState?.lastTokenResponse?.idToken
    }
}
