//
//  IBiometricManager.swift
//  StrivacityTests
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation

/**
 * Protocol specifies methods which have to be implemented by class that performs biometric authentication.
 */
public protocol IBiometricManager {
    
    /**
     * Checks if the device supports biometric authentication
     *
     * - Returns: Boolean result, true if the biometric authentication supported, false othervise.
     */
    func isBiometricSupported() -> Bool
    
    /**
     * Performs biometric authentication.
     *
     * - Parameter callback: takes boolean value, that indicates the result of biometric authentication.
     */
    func authenticate(_ callback: @escaping (Bool) -> Void)
}
