//
//  JwksUrlDataManager.swift
//  Strivacity
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation

/**
 * Manages obtaining data from the jwks url and creation [JwksUrlData] object
 */
class JwksUrlDataManager: IJwksUrlDataManager {
    /// Object manages obtaining data from url
    let urlSessionManager: IUrlSessionManager
    
    /**
     * Initialises with the object which handles obtaining data from the jwks url.
     *
     * - Parameter urlSessionmanager: specifies object which manages data obtaining.
     */
    init(_ urlSessionManager: IUrlSessionManager = UrlSessionManager()) {
        self.urlSessionManager = urlSessionManager
    }
    
    /**
      Obtains raw data from the jwks url and creates [JwksUrlData] object from it.
     
      - Parameters:
        - jwksUrl: The url which contains needed data.
        - idTokenHeader: [IdTokenHeader] object it's members are used
        to find the data for current id token among data obtained from jwks url.
        - error: An error which can occur
        (it is passed as inout parameter so, its value can be set inside the function).
     
      - Returns: Valid [JwksUrlData] object is returned on success or nil on failure.
     */
    func obtainJwksUrlData(jwksUrl: URL, idTokenHeader: IdTokenHeader, error: inout NSError?) -> JwksUrlData? {
        let (data, dataObtainingError) = self.urlSessionManager.getDataFromUrl(jwksUrl)
        guard let data = data else {
            error = dataObtainingError
            print("Failed to obtain data from jwksUrl.")
            return nil
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, AnyObject> else {
            error = APIError.failedToCreateJsonFromJwksUrlData as NSError
            print("Failed to create json from jwksUrl data.")
            return nil
        }
        
        let jwksUrlData = self.createJwksUrlDataObject(from: json, with: idTokenHeader, error: &error)
        if jwksUrlData == nil && error == nil {
            error = APIError.failedToFindObjectWithProperKeyId as NSError
        }
        
        return jwksUrlData
    }
    
    /**
      Creates [JwksUrlData] object
     
      - Parameters:
        - json: Dictionary object created with data obtained from jwks url, it has specific structure,
        it has an Array object which can be obtained by Constants.jwksUrlObjectKey key from it,
        then inside the array it can have dictionaries, we need to find appropriate dictionary using [IdTokenHeader] object
        - idTokenHeader: [IdTokenHeader] object which is used to find appropriate data inside dictionary.
        - error: An error which can occur during the dictionary parsing
        (it is passed as inout parameter so, its value can be set inside the function).
     
      - Returns: Valid [JwksUrlData] object on success or nil on failure.
     */
    private func createJwksUrlDataObject(from json: Dictionary<String, AnyObject>, with idTokenHeader: IdTokenHeader, error: inout NSError?) -> JwksUrlData? {
        var jwksUrlData: JwksUrlData?
        guard let array = json[Constants.jwksUrlObjectKey] as? Array<AnyObject> else {
            error = APIError.unexpectedJsonConfiguration as NSError
            return nil
        }
        
        for dict in array {
            guard let dict = dict as? Dictionary<String, AnyObject> else {
                error = APIError.failedToUnwrapDictionary as NSError
                continue
            }
            
            let algorithm = dict[Constants.algorithmKey] as? String
            let keyId = dict[Constants.keyIdKey] as? String
            if let algorithm = algorithm, let keyId = keyId, algorithm == idTokenHeader.algProperty, keyId == idTokenHeader.kidProperty {
                let exponent = dict[Constants.exponentKey] as? String ?? ""
                let keyType = dict[Constants.keyTypeKey] as? String ?? ""
                let modulus = dict[Constants.modulusKey] as? String ?? ""
                let usage = dict[Constants.usageKey] as? String ?? ""
                jwksUrlData = JwksUrlData(algorithm: algorithm, exponent: exponent, keyId: keyId, keyType: keyType, modulus: modulus, usage: usage)
                break
            }
        }
        
        if jwksUrlData != nil {
            error = nil
        }
        
        return jwksUrlData
    }
}
