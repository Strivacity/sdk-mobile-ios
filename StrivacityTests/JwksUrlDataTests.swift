//
//  JwksUrlDataTests.swift
//  StrivacityTests
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation
import XCTest
@testable import Strivacity

final class JwksUrlDataTests: XCTestCase {
    var jwksUrlData: JwksUrlData?
    

    override func setUp() {
        jwksUrlData = TestConstants.validJwksUrlData
    }
    
    override func tearDown() {
        jwksUrlData = nil
    }
    
    func testJwksUrlDataNotNil() {
        XCTAssertNotNil(jwksUrlData)
    }
    
    func testJwksUrlDataGetPropertiesSuccess() {
        XCTAssertEqual(jwksUrlData, TestConstants.validJwksUrlData)
    }
}
