//
//  IAuthState.swift
//  Strivacity
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation
import AppAuth

/**
 * Protocol specifies methods which have to be implemented by class that manages authorization state.
 */
protocol IAuthStateProvider {
    
    /**
     * Sets auth state directly using the OIDAuthState object
     *
     * - Parameter state: Authorization state to be set as current
     * the value of the state can be nil, in this case the authorization state is reset
     */
    func setAuthState(_ state: OIDAuthState?)
    
    /**
     * Sets auth state obtained from the OIDAuthorizationResponse object
     *
     * - Parameter state: OIDAuthorizationResponse with auth state
     */
    func setAuthState(_ authResponse: OIDAuthorizationResponse)
    
    /**
     * Sets auth state obtained from the OIDAuthorizationResponse and OIDTokenResponse
     *
     * - Parameters:
     *   - state: Auth response used for auth state creation
     *   - tokenResponse: Token response used for auth state creation
     */
    func setAuthState(_ authResponse: OIDAuthorizationResponse, tokenResponse: OIDTokenResponse?)
    
    /**
     * Returns token exchange request obtained from current auth state.
     *
     * - Returns: OIDTokenRequest object on success or nil on failure.
     */
    func getTokenExchangeRequest() -> OIDTokenRequest?
    
    /**
     * Performs auth state update using the token response.
     *
     * - Parameters:
     *   - tokenResponse: Token response to update current auth state.
     *   - error: Error which could be occured when token response has been obtained.
     */
    func update(_ tokenResponse: OIDTokenResponse?, error: NSError?)
    
    /**
     * Provides current auth state.
     *
     * - Returns: auth state
     */
    func getAuthState() -> AnyObject?
    
    /**
     * Provides id token string obtained from current auth state or nil if there is no one id token stored.
     *
     * - Returns: id token string
     */
    func getIdToken() -> String?
}
