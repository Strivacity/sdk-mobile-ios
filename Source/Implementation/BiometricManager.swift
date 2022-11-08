//
//  BiometricManager.swift
//  Strivacity
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation
import LocalAuthentication

/**
 * Performs biometric authentication.
 */
class BiometricManager: IBiometricManager {
    /// Biometric authentication context.
    private var context: LAContext = LAContext()
    /// Variable indicates possibility of biometric authentication on current device.
    private var biometricSupported: Bool?
    
    /**
     * Initializes with context for biometric authentication.
     *
     * - Parameter context: Biometric authentication context.
     */
    init(context: LAContext) {
        self.context = context
    }
    
    /**
     * Checks if the device supports biometric authentication
     *
     * - Returns: Boolean result, true if the biometric authentication supported, false othervise.
     */
    func isBiometricSupported() -> Bool {
        if let biometricSupported = biometricSupported {
            return biometricSupported
        }
        
        var error: NSError?
        let result = context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
        if let error = error {
            print("Failed to evaluate policy, error - \(error.localizedDescription)")
        }
        biometricSupported = result
        
        return result
    }
    
    /**
     * Performs biometric authentication.
     *
     * - Parameter callback: takes boolean value, that indicates the result of biometric authentication.
     */
    func authenticate(_ callback: @escaping (Bool) -> Void) {
        let reason = "Perform authentication"
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, error in
            if !success {
                print("Failed to authenticate with error - \(error?.localizedDescription ?? "")")
            }
            
            DispatchQueue.main.async {
                callback(success)
            }
        }
    }
}
