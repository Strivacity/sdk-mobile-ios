//
//  IAuthClient.swift
//  Strivacity
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import UIKit

/**
 * Protocol for dispatching requests to authentication Strivacity APIs.
 */
public protocol IAuthClient {
    
    /**
     * Sends an authorization request to perform authorization flow
     * [See Strivacity APIs, Authentication APIs, Begin an OIDC Authorization Code Flow](https://api.strivacity.com/)
     * [See OpenID Connect Core 1.0, Section 3.1](https://openid.net/specs/openid-connect-core-1_0.html#CodeFlowAuth)
     *
     * - Parameters:
     *   - viewController: The UIViewController to present auth flow request.
     *   - completion: The callback to invoke upon request completion.
     */
    func authorizeAuthCodeFlow(viewController: UIViewController, completion: @escaping (Result<AnyObject, Error>) -> Void)
    
    /**
     * Sends an authorization request to perform hybrid flow
     * [See Strivacity APIs, Authentication APIs, Begin an OIDC Hybrid Flow](https://api.strivacity.com/)
     * [See OpenID Connect Core 1.0, Section 3.3](https://openid.net/specs/openid-connect-core-1_0.html#HybridFlowAuth)
     *
     * - Parameters:
     *   - viewController: The UIViewController to present hybrid flow request.
     *   - completion: The callback to invoke upon request completion.
     */
    func authorizeHybridFlow(viewController: UIViewController, completion: @escaping (Result<AnyObject, Error>) -> Void)
    
    /**
     * Sends request to obtain an id token from auth code
     * [See Strivacity Authentication APIs, Obtain an ID Token from an Authorization Code](https://api.strivacity.com/)
     * [See OpenID Connect Core 1.0, Section 2](https://openid.net/specs/openid-connect-core-1_0.html#IDToken)
     * Note: The authorization code must already be obtained from [authorizeAuthCodeFlow] or [authorizeHybridFlow]
     *
     * - Parameter completion: The callback to invoke upon request completion.
     */
    func requestIdToken(completion: @escaping (Result<AnyObject, Error>) -> Void)
    
    /**
     * Sends request to obtain an access token via client credentials
     * [See Strivacity Authentication APIs, Obtain an Access Token via Client Credentials](https://api.strivacity.com/)
     *
     * - Parameter completion: The callback to invoke upon request completion.
     */
    func requestAccessToken(viewController: UIViewController, completion: @escaping (Result<AnyObject, Error>) -> Void)
    
    /**
     * Sends request to perform logout
     * [See Strivacity Authentication APIs, Begin an OIDC Initiated Logout](https://api.strivacity.com/)
     * [See OpenID Connect RP-Initiated Logout 1.0 - draft 01](https://openid.net/specs/openid-connect-rpinitiated-1_0.html)
     *
     * - Parameters:
     *   - viewController: The UIViewController to present logout request.
     *   - completion: The callback to invoke upon request completion.
     */
    func logout(viewController: UIViewController, completion: @escaping (Result<Bool, Error>) -> Void)
    
    /**
     * Gives actual [authentication state](OIDAuthState)
     *
     * - Returns: authentication state
     */
    func getAuthState() -> AnyObject?
    
    /**
     * Handles the redirect of the authorization response url.
     *
     * - Parameter url: authorization response url
     *
     * - Returns: result of redirection, true on success, false on failure.
     */
    func proceedExternalUserAgentFlow(with url: URL) -> Bool
}
