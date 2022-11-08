//
//  UrlFactory.swift
//  Strivacity
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation

/**
 * Creates basic OAuth 2.0 endpoints URLs
 */
class UrlFactory: IUrlFactory {
    /// object provides basic endpoints
    private let endpoints: IEndpoints
    
    /**
     * Creates authorization url for the specified domain.
     *
     * - Parameter endpoints: object provides basic endpoints
     */
    init(_ endpoints: IEndpoints = Endpoints()) {
        self.endpoints = endpoints
    }
    
    /**
     * Creates authorization url for the specified domain.
     *
     * - Parameter domain: domain, auth url should be created with.
     *
     * - Returns: auth url
     */
    public func getAuthServerHost(for domain: String) -> URL? {
        return URL(string: domain + self.endpoints.getAuthEndpoint())
    }
    
    /**
      Creates logout url for the specified domain with or without https prefix.
     
      - Parameters:
        - domain: domain, logout url should be created with.
        - shouldAddHttpsPrefix: specifies should the https prefix be used.
     
      - Returns: logout url
     */
    public func getLogoutUrl(for domain: String, shouldAddHttpsPrefix: Bool) -> URL? {
        let string = (shouldAddHttpsPrefix ? Constants.httpsPrefix : "") + domain + self.endpoints.getLogoutEndpoint()
        return URL(string: string)
    }
    
    /**
     * Creates token request url for the specified domain.
     *
     * - Parameter domain: domain, token request url should be created with.
     *
     * - Returns: token request url
     */
    public func getTokenRequestUrl(for domain: String) -> URL? {
        return URL(string: domain + self.endpoints.getTokenEndpoint())
    }
}

