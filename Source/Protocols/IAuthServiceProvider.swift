//
//  IAuthServiceProvider.swift
//  Strivacity
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation
import AppAuth

/**
 * Protocol specifies methods which have to be implemented by class that manages authorization requests to the AppAuth framework.
 */
protocol IAuthServiceProvider {
    
    /**
     * Performs obtaining service configuration for specified domain.
     *
     * - Parameter url: Domain for which the configuration should be obtained.
     *
     * - Returns: Service configuration and nil as error on success or nil as configuration and error on failure.
     */
    func discoverServiceConfig(for url: URL) -> (OIDServiceConfiguration?, NSError?)
    
    /**
     * Presents authorization request.
     *
     * - Parameters:
     *   - request: Request to be presented.
     *   - viewController: The UIViewController to present auth request.
     *
     * - Returns: User session, auth response and nil as error on success or nil as session and response and error on failure.
     */
    func presentAuthRequest(_ request: OIDAuthorizationRequest, viewController: UIViewController) -> (OIDExternalUserAgentSession?, OIDAuthorizationResponse?, NSError?)
    
    /**
     * Presents hybrid flow request.
     *
     * - Parameters:
     *   - requestUrl: Url which is used in hybrid flow request.
     *   - scheme: Scheme which is used for hybrid flow request.
     *   - userAgent: Agent that takes part in hybrd flow request presentation.
     *
     * - Returns: URL and nil as error on success or nil as URL and error on failure.
     */
    func presentHybridFlowRequest(_ requestUrl: URL, scheme: String?, userAgent: OIDExternalUserAgentIOS) -> (URL?, NSError?)
    
    /**
     * Presents token request.
     *
     * - Parameter request: Request to be presented.
     *
     * - Returns: Response and nil as error on success or nil as response and error on failure.
     */
    func performTokenRequest(_ request: OIDTokenRequest) -> (OIDTokenResponse?, NSError?)
    
    /**
     * Presents end session request.
     *
     * - Parameters:
     *   - request: Request to be presented.
     *   - externalUserAgent: Agent that takes part in end session request.
     *
     * - Returns: Response, session and nil as error on success or nil as response and session and error on failure.
     */
    func presentEndSessionRequest(_ request: OIDEndSessionRequest, externalUserAgent: OIDExternalUserAgent) -> (OIDEndSessionResponse?, OIDExternalUserAgentSession?, NSError?)
}
