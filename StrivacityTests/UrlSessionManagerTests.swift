//
//  UrlSessionManagerTests.swift
//  StrivacityTests
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation
import AppAuth
import XCTest
@testable import Strivacity

class MockUrlSessionValid: URLSession {
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        completionHandler(Data(), nil, nil)
        return URLSession.shared.dataTask(with: url)
    }
}

class MockUrlSessionInvalid: URLSession {
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        completionHandler(nil, nil, APIError.unexpectedError)
        return URLSession.shared.dataTask(with: url)
    }
}

class UrlSessionManagerTests: XCTestCase {
    var urlSessionManager: IUrlSessionManager?
    
    func testGetDataSuccess() {
        urlSessionManager = UrlSessionManager(MockUrlSessionValid())
        let result = urlSessionManager?.getDataFromUrl(TestConstants.validJwksUrl)
        
        XCTAssertNotNil(result?.0)
        XCTAssertNil(result?.1)
    }
    
    func testGetDataFailure() {
        urlSessionManager = UrlSessionManager(MockUrlSessionInvalid())
        let result = urlSessionManager?.getDataFromUrl(TestConstants.wrongJwksUrl)
        
        XCTAssertNil(result?.0)
        XCTAssertEqual(APIError.failedToObtainDataFromJwksUrl as NSError, result?.1)
    }
}
