//
//  IProviderCallback.swift
//  Strivacity
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation

/**
 * Interface for callbacks to handle [AuthClient] creation.
 * Called in [AuthProvider.provide] after the user has created [AuthClient] object
 */
public protocol IProviderCallback {
    /**
     * Invoked after successful [AuthClient] creation.
     */
    func onSuccess(authClient: AuthClient)
    
    /**
     * Invoked after completion with error of the [AuthClient] creation.
     */
    func onError(error: NSError)
}
