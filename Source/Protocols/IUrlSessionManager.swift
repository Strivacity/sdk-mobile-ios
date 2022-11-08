//
//  IUrlSessionManager.swift
//  Strivacity
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation

/**
 * Protocol specifies method which has to be implemented by class manages obtaining data from URL.
 */
protocol IUrlSessionManager {
    
    /**
     * Performs obtaining data from specified URL.
     *
     * - Parameter url: The object from which to obtain data.
     *
     * - Returns: Data object and nil as error on success or nil as data and error on failure.
     */
    func getDataFromUrl(_ url: URL) -> (Data?, NSError?)
}
