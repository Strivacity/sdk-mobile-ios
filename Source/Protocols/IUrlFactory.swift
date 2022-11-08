//
//  IUrlFactory.swift
//  Strivacity
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation

/**
 * Protocol specifies methods which create basic OAuth 2.0 endpoint URLs.
 */
protocol IUrlFactory {
    
    /**
     * Creates authorization url for the specified domain.
     *
     * - Parameter domain: domain, auth url should be created with.
     *
     * - Returns: auth url
     */
    func getAuthServerHost(for domain: String) -> URL?
    
    /**
     * Creates logout url for the specified domain with or without https prefix.
     *
     * - Parameters:
     *   - domain: domain, logout url should be created with.
     *   - shouldAddHttpsPrefix: specifies should the https prefix be used.
     *
     * - Returns: logout url
     */
    func getLogoutUrl(for domain: String, shouldAddHttpsPrefix: Bool) -> URL?
    
    /**
     * Creates token request url for the specified domain.
     *
     * - Parameter domain: domain, token request url should be created with.
     *
     * - Returns: token request url
     */
    func getTokenRequestUrl(for domain: String) -> URL?
}
