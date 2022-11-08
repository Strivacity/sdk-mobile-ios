//
//  IValidationManager.swift
//  Strivacity
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation

/**
 * Protocol specifies method which should be implemented by object which validates id token.
 */
protocol IValidationManager {
    
    /**
     * Validates the id token string
     *
     * - Parameters:
     *   - idTokenString: String value obtained using AppAuth framework and passed for validation.
     *   - authorizationCode: String value obtained using AppAuth framework and passed for validation.
     *   - clientId: used for id token validation.
     *   - nonce: used for id token validation.
     *   - config: used for id token validation.
     *   - jwksUrl: URL which contains data needed for validation process.
     *   - error: An error which can occur during the validation,
     *   (it is passed as inout parameter so, its value can be set inside the function).
     *
     * - Returns: Boolean value is returned, true on success or false on failure.
     */
    func validate(idTokenString: String?, authorizationCode: String?, clientId: String, nonce: String, jwksUrl: URL, config: Config, error: inout NSError?) -> Bool
}
