//
//  IPublicKeyCreator.swift
//  Strivacity
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation

/**
 * Protocol specifies method which should be implemented by object which creates public key.
 */
protocol IPublicKeyCreator {
    
    /**
     * Creates public key
     *
     * - Parameters:
     *   - modulus: String value obtained from the jwks url.
     *   - exponent: String value obtained from the jwks url.
     *
     * - Returns: Public key is returned on success or nil on failure.
     */
    func createPublicKey(modulus: String, exponent: String) -> SecKey?
}
