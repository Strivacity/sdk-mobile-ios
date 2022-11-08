//
//  JwksUrlDataManagerTests.swift
//  StrivacityTests
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation
import XCTest
@testable import Strivacity

final class JwksUrlDataManagerTests: XCTestCase {
    var jwksUrlDataManager: IJwksUrlDataManager?
    
    override func tearDown() {
        jwksUrlDataManager = nil
    }
    
    func testObtainJwksUrlDataGotNilDataFromUrl() {
        jwksUrlDataManager = JwksUrlDataManager(StubUrlSessionManagerNilData())
        var error: NSError?
        let jwksUrlData = jwksUrlDataManager?.obtainJwksUrlData(jwksUrl: TestConstants.validJwksUrl, idTokenHeader: IdTokenData.validHeader, error: &error)
        XCTAssertEqual(jwksUrlData, nil)
        XCTAssertEqual(error, APIError.failedToObtainDataFromJwksUrl as NSError)
    }
    
    func testObtainJwksUrlDataWrongUrl() {
        jwksUrlDataManager = JwksUrlDataManager()
        var error: NSError?
        let jwksUrlData = jwksUrlDataManager?.obtainJwksUrlData(jwksUrl: TestConstants.wrongJwksUrl, idTokenHeader: IdTokenData.validHeader, error: &error)
        XCTAssertEqual(jwksUrlData, nil)
        XCTAssertEqual(error, APIError.failedToCreateJsonFromJwksUrlData as NSError)
    }
    
    func testObtainJwksUrlDataWrongData() {
        jwksUrlDataManager = JwksUrlDataManager(StubUrlSessionManagerWrongJson())
        var error: NSError?
        let jwksUrlData = jwksUrlDataManager?.obtainJwksUrlData(jwksUrl: TestConstants.validJwksUrl, idTokenHeader: IdTokenData.validHeader, error: &error)
        XCTAssertEqual(jwksUrlData, nil)
        XCTAssertEqual(error, APIError.failedToCreateJsonFromJwksUrlData as NSError)
    }
    
    func testObtainJwksUrlDataUnexpectedJsonConfiguration() {
        jwksUrlDataManager = JwksUrlDataManager(StubUrlSessionManagerUnexpectedJsonConfiguration())
        var error: NSError?
        let jwksUrlData = jwksUrlDataManager?.obtainJwksUrlData(jwksUrl: TestConstants.validJwksUrl, idTokenHeader: IdTokenData.validHeader, error: &error)
        XCTAssertEqual(jwksUrlData, nil)
        XCTAssertEqual(error, APIError.unexpectedJsonConfiguration as NSError)
    }
    
    func testObtainValidJwksUrlData() {
        jwksUrlDataManager = JwksUrlDataManager(StubUrlSessionManagerValidData())
        var error: NSError?
        let jwksUrlData = jwksUrlDataManager?.obtainJwksUrlData(jwksUrl: TestConstants.validJwksUrl, idTokenHeader: IdTokenData.validHeader, error: &error)
        XCTAssertNotEqual(jwksUrlData, nil)
        XCTAssertEqual(error, nil)
    }
    
    func testObtainJwkssUrlDataInvalidHeader() {
        jwksUrlDataManager = JwksUrlDataManager(StubUrlSessionManagerValidData())
        var error: NSError?
        let jwksUrlData = jwksUrlDataManager?.obtainJwksUrlData(jwksUrl: TestConstants.validJwksUrl, idTokenHeader: IdTokenHeader(), error: &error)
        XCTAssertEqual(jwksUrlData, nil)
        XCTAssertEqual(error, APIError.failedToFindObjectWithProperKeyId as NSError)
    }
}
