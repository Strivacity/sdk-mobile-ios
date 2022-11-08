//
//  UrlSessionManager.swift
//  Strivacity
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation

/**
 * Manages obtaining data object from url using URLSession object that is passed to initializer.
 * If it is needed, this approach gives us the ability to change the way the data is obtained
 * by passing the object inherited from URLSession in initializer.
 */
class UrlSessionManager: IUrlSessionManager {
    /// object that handles data obtaining
    private let urlSession: URLSession
    
    /**
     * Initialises with URLSession
     *
     * - Parameter urlSession: The object which handles data obtaining.
     */
    init(_ urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    /**
     * Performs obtaining data from specified URL.
     *
     * - Parameter url: The object from which to obtain data.
     *
     * - Returns: Data object and nil as error on success or nil as data and error on failure.
     */
    func getDataFromUrl(_ url: URL) -> (Data?, NSError?) {
        var internalError: NSError?
        var urlData: Data?
        
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global(qos: .utility).async {
            let task = self.urlSession.dataTask(with: url) { (data, _, _) in
                guard let data = data else {
                    internalError = APIError.failedToObtainDataFromJwksUrl as NSError
                    print("Failed to unwrap jwksUrl data.")
                    group.leave()
                    return
                }

                urlData = data
                group.leave()
            }

            task.resume()
        }

        group.wait()
        
        return (urlData, internalError)
    }
}
