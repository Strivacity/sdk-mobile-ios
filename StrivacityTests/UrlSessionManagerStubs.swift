//
//  UrlSessionManagerStubs.swift
//  StrivacityTests
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation
import XCTest
@testable import Strivacity

class StubUrlSessionManagerNilData: IUrlSessionManager {
    func getDataFromUrl(_ url: URL) -> (Data?, NSError?) {
        return (nil, APIError.failedToObtainDataFromJwksUrl as NSError)
    }
}

class StubUrlSessionManagerUnexpectedJsonConfiguration: IUrlSessionManager {
    func getDataFromUrl(_ url: URL) -> (Data?, NSError?) {
        guard let dictionary = Dictionary(dictionaryLiteral: (Constants.algorithmKey, TestConstants.testAlgorithm), (Constants.exponentKey, TestConstants.testExponent), (Constants.keyIdKey, TestConstants.testKeyId), (Constants.keyTypeKey, TestConstants.testKeyType), (Constants.modulusKey, TestConstants.testModulus), (Constants.usageKey, TestConstants.testUsage)) as? Dictionary<String, AnyObject> else {
            return (nil, nil)
        }
        
        if let data = try? JSONSerialization.data(withJSONObject: dictionary, options: .fragmentsAllowed) {
            return (data, nil)
        }
        
        return (nil, nil)
    }
}

class StubUrlSessionManagerWrongJson: IUrlSessionManager {
    func getDataFromUrl(_ url: URL) -> (Data?, NSError?) {
        guard let dictionary = Dictionary(dictionaryLiteral: (Constants.algorithmKey, TestConstants.testAlgorithm), (Constants.exponentKey, TestConstants.testExponent), (Constants.keyIdKey, TestConstants.testKeyId), (Constants.keyTypeKey, TestConstants.testKeyType), (Constants.modulusKey, TestConstants.testModulus), (Constants.usageKey, TestConstants.testUsage)) as? Dictionary<String, AnyObject> else {
            return (nil, nil)
        }
        
        if let data = try? JSONSerialization.data(withJSONObject: Array(arrayLiteral: dictionary), options: .fragmentsAllowed) {
            return (data, nil)
        }
        
        return (nil, nil)
    }
}

class StubUrlSessionManagerValidData: IUrlSessionManager {
    func getDataFromUrl(_ url: URL) -> (Data?, NSError?) {
        guard let dictionary = Dictionary(dictionaryLiteral: (Constants.algorithmKey, TestConstants.testAlgorithm), (Constants.exponentKey, TestConstants.testExponent), (Constants.keyIdKey, TestConstants.testKeyId), (Constants.keyTypeKey, TestConstants.testKeyType), (Constants.modulusKey, TestConstants.testModulus), (Constants.usageKey, TestConstants.testUsage)) as? Dictionary<String, AnyObject> else {
            return (nil, nil)
        }
        
        if let data = try? JSONSerialization.data(withJSONObject: Dictionary(dictionaryLiteral: ("keys", [dictionary])), options: .fragmentsAllowed) {
            return (data, nil)
        }
        
        return (nil, nil)
    }
}
