//
//  IEndpoints.swift
//  Strivacity
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation

/**
 * Protocol for obtaining basic OAuth2 endpoints.
 */
protocol IEndpoints {
    
    /**
     * Gives basic part of authorization endpoint
     *
     * - Returns: auth endpoint
     */
    func getAuthEndpoint() -> String
    
    /**
     * Gives basic part of end session endpoint
     *
     * - Returns: logout endpoint
     */
    func getLogoutEndpoint() -> String
    
    /**
     * Gives basic part of token endpoint
     *
     * - Returns: token endpoint
     */
    func getTokenEndpoint() -> String
}
