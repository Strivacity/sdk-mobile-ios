//
//  Endpoints.swift
//  Strivacity
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation

/**
 * Creates basic OAuth2 endpoints.
 */
class Endpoints: IEndpoints {
    
    /**
     * Gives basic part of authorization endpoint
     *
     * - Returns: auth endpoint
     */
    func getAuthEndpoint() -> String {
        return Constants.authPart
    }
    
    /**
     * Gives basic part of end session endpoint
     *
     * - Returns: logout endpoint
     */
    func getLogoutEndpoint() -> String {
        return Constants.logoutPart
    }
    
    /**
     * Gives basic part of token endpoint
     *
     * - Returns: token endpoint
     */
    func getTokenEndpoint() -> String {
        return Constants.endpointTokenPart
    }
}
