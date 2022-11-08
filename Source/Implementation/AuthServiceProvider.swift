//
//  AuthServiceProvider.swift
//  Strivacity
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation
import AuthenticationServices
import AppAuth

/**
 * Manages requests to the AppAuth framework via the IAuthService object.
 */
class AuthServiceProvider: IAuthServiceProvider {
    /// queue that synchronises access to the authService object
    private let authServiceProviderQueue: DispatchQueue = DispatchQueue(label: "com.strivacity.auth.service.provider.queue", attributes: .concurrent)
    /// group that gives us the ability to wait and return the obtained result
    private let group: DispatchGroup = DispatchGroup()
    /// object that handles communication with AppAuth framework
    private let authService: IAuthService
    
    /**
     * Initialises with the object that handles communication with AppAuth framework
     *
     * - Parameter authService: object that performs requests to the AppAuth framework.
     */
    init(_ authService: IAuthService = AuthService()) {
        self.authService = authService
    }
    
    /**
     * Performs obtaining service configuration for specified domain.
     *
     * - Parameter url: Domain for which the configuration should be obtained.
     *
     * - Returns: Service configuration and nil as error on success or nil as configuration and error on failure.
     */
    func discoverServiceConfig(for url: URL) -> (OIDServiceConfiguration?, NSError?) {
        var configuration: OIDServiceConfiguration?
        var currentError: NSError?
        
        authServiceProviderQueue.sync(flags: .barrier, execute: {
            group.enter()
            self.authService.discoverServiceConfig(for: url) { serviceConfig, error in
                if serviceConfig == nil {
                    currentError = error as? NSError
                    print("Error to retrieve service configuration: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                }
                
                configuration = serviceConfig
                self.group.leave()
            }
            
            group.wait()
        })
        
        return (configuration, currentError)
    }
    
    /**
     * Presents authorization request.
     *
     * - Parameters:
     *   - request: Request to be presented.
     *   - viewController: The UIViewController to present auth request.
     *
     * - Returns: User session, auth response and nil as error on success or nil as session and response and error on failure.
     */
    func presentAuthRequest(_ request: OIDAuthorizationRequest, viewController: UIViewController) -> (OIDExternalUserAgentSession?, OIDAuthorizationResponse?, NSError?) {
        var currentAuthFlow: OIDExternalUserAgentSession?
        var authResponse: OIDAuthorizationResponse?
        var currentError: NSError?
        
        authServiceProviderQueue.sync(flags: .barrier, execute: {
            group.enter()
            currentAuthFlow = self.authService.presentAuthRequest(request, viewController: viewController) { response, error in
                if response == nil {
                    currentError = error as? NSError
                    print("Error to retrieve auth response: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                }
                
                authResponse = response
                self.group.leave()
            }
            group.wait()
        })
        
        return (currentAuthFlow, authResponse, currentError)
    }
    
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
    func presentHybridFlowRequest(_ requestUrl: URL, scheme: String?, userAgent: OIDExternalUserAgentIOS) -> (URL?, NSError?) {
        var responseUrl: URL?
        var currentError: NSError?
        
        authServiceProviderQueue.sync(flags: .barrier, execute: {
            group.enter()
            self.authService.presentHybridFlowRequest(requestUrl, scheme: scheme, userAgent: userAgent) { url, error in
                if let unwrappedUrl = url {
                    responseUrl = unwrappedUrl
                } else {
                    let err = OIDErrorUtilities.error(with: OIDErrorCode.userCanceledAuthorizationFlow, underlyingError: error, description: "")
                    print("User canceled authorization flow, error: \(err)")
                    currentError = err as NSError
                }
                
                self.group.leave()
            }
            group.wait()
        })
        
        return (responseUrl, currentError)
    }
    
    /**
     * Presents token request.
     *
     * - Parameter request: Request to be presented.
     *
     * - Returns: Response and nil as error on success or nil as response and error on failure.
     */
    func performTokenRequest(_ request: OIDTokenRequest) -> (OIDTokenResponse?, NSError?) {
        var response: OIDTokenResponse?
        var currentError: NSError?
        
        authServiceProviderQueue.sync(flags: .barrier, execute: {
            group.enter()
            self.authService.performTokenRequest(request) { tokenResponse, error in
                response = tokenResponse
                currentError = error as? NSError
                self.group.leave()
            }
            group.wait()
        })
        
        return (response, currentError)
    }
    
    /**
     * Presents end session request.
     *
     * - Parameters:
     *   - request: Request to be presented.
     *   - externalUserAgent: Agent that takes part in end session request.
     *
     * - Returns: Response, session and nil as error on success or nil as response and session and error on failure.
     */
    func presentEndSessionRequest(_ request: OIDEndSessionRequest, externalUserAgent: OIDExternalUserAgent) -> (OIDEndSessionResponse?, OIDExternalUserAgentSession?, NSError?) {
        var endSessionResponse: OIDEndSessionResponse?
        var session: OIDExternalUserAgentSession?
        var currentError: NSError?
        
        authServiceProviderQueue.sync(flags: .barrier, execute: {
            group.enter()
            session = self.authService.presentEndSessionRequest(request, externalUserAgent: externalUserAgent) { response, error in
                endSessionResponse = response
                currentError = error as? NSError
                self.group.leave()
            }
            group.wait()
        })
            
        return (endSessionResponse, session, currentError)
    }
}
