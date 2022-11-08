//
//  IJwksUrlDataManager.swift
//  Strivacity
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation

/**
 * Protocol specifies method which should be implemented by object which manages and validates data obtained from the jwks url.
 */
protocol IJwksUrlDataManager {
    
    /**
     * Obtains raw data from the jwks url and creates [JwksUrlData] object from it.
     *
     * - Parameters:
     *   - jwksUrl: The url which contains needed data.
     *   - idTokenHeader: [IdTokenHeader] object it's members are used
     *   to find the data for current id token among data obtained from jwks url.
     *   - error: An error which can occur
     *   (it is passed as inout parameter so, its value can be set inside the function).
     *
     * - Returns: Valid [JwksUrlData] object is returned on success or nil on failure.
     */
    func obtainJwksUrlData(jwksUrl: URL, idTokenHeader: IdTokenHeader, error: inout NSError?) -> JwksUrlData?
}
