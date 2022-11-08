//
//  AuthService.swift
//  Strivacity
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation
import AuthenticationServices
import AppAuth

/**
 * Performs requests to the AppAuth framework.
 */
class AuthService: IAuthService {
    
    /**
     * Performs obtaining service configuration for specified domain.
     *
     * - Parameters:
     *   - url: Domain for which the configuration should be obtained.
     *   - callback: The callback to invoke after service configuration obtaining.
     */
    func discoverServiceConfig(for url: URL, callback: @escaping (OIDServiceConfiguration?, Error?) -> Void) {
        OIDAuthorizationService.discoverConfiguration(forIssuer: url, completion: callback)
    }
    
    /**
     * Presents authorization request.
     *
     * - Parameters:
     *   - request: Request to be presented.
     *   - viewController: The UIViewController to present auth request.
     *   - callback: The callback to invoke upon request completion.
     *
     * - Returns: User session on success or nil on failure.
     */
    func presentAuthRequest(_ request: OIDAuthorizationRequest, viewController: UIViewController, callback: @escaping (OIDAuthorizationResponse?, Error?) -> Void) -> OIDExternalUserAgentSession? {
        DispatchQueue.main.sync {
            return OIDAuthorizationService.present(request, presenting: viewController, callback: callback)
        }
    }
    
    /**
     * Presents hybrid flow request.
     *
     * - Parameters:
     *   - requestUrl: Url which is used in hybrid flow request.
     *   - scheme: Scheme which is used for hybrid flow request.
     *   - userAgent: Agent that takes part in hybrd flow request presentation.
     *   - callback: The callback to invoke upon request completion.
     */
    func presentHybridFlowRequest(_ requestUrl: URL, scheme: String?, userAgent: OIDExternalUserAgentIOS, callback: @escaping (URL?, Error?) -> Void) {
        DispatchQueue.main.async {
            let authenticationSession = ASWebAuthenticationSession(url: requestUrl, callbackURLScheme: scheme, completionHandler: callback)
            if let externalUserAgent = userAgent as? ASWebAuthenticationPresentationContextProviding {
                authenticationSession.presentationContextProvider = externalUserAgent
            }
            
            authenticationSession.start()
        }
    }
    
    /**
     * Presents token request.
     *
     * - Parameters:
     *   - request: Request to be presented.
     *   - callback: The callback to invoke upon request completion.
     */
    func performTokenRequest(_ request: OIDTokenRequest, callback: @escaping (OIDTokenResponse?, Error?) -> Void) {
        DispatchQueue.main.async {
            OIDAuthorizationService.perform(request, callback: callback)
        }
    }
    
    /**
     * Presents end session request.
     *
     * - Parameters:
     *   - request: Request to be presented.
     *   - externalUserAgent: Agent that takes part in end session request.
     *   - callback: The callback to invoke upon request completion.
     *
     * - Returns: Session on success or nil on failure.
     */
    func presentEndSessionRequest(_ request: OIDEndSessionRequest, externalUserAgent: OIDExternalUserAgent, callback: @escaping (OIDEndSessionResponse?, Error?) -> Void) -> OIDExternalUserAgentSession? {
        DispatchQueue.main.sync {
            return OIDAuthorizationService.present(request, externalUserAgent: externalUserAgent, callback: callback)
        }
    }
}
