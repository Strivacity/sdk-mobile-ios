//
//  ISecureStorage.swift
//  Strivacity
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation

/**
 * Protocol specifies methods which should be implemented by object which manages auth state storing.
 */
protocol ISecureStorage {
    
    /**
     * Performs auth state storing.
     *
     * - Parameters:
     *   - authInfo: The auth state to be stored.
     *   - completion: The callback to invoke upon storing completion.
     */
    func setAuthInfo(authInfo: AnyObject, completion: @escaping (Result<Bool, Error>) -> Void)
    
    /**
     * Returns stored auth state.
     *
     * - Returns: Valid auth state object if the stored object is or nil if no one object is stored.
     */
    func getAuthInfo() -> AnyObject?
    
    /**
     * Removes stored auth state.
     *
     * - Parameter completion: The callback to invoke upon removal completion.
     */
    func removeAuthInfo(completion: @escaping (Result<Bool, Error>) -> Void)
}
