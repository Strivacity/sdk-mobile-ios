//
//  EndpointTests.swift
//  StrivacityTests
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation
import XCTest
@testable import Strivacity

final class EndpointTests: XCTestCase {
    var endpoints: Endpoints?
    
    override func setUp() {
        endpoints = Endpoints()
    }
    
    override func tearDown() {
        endpoints = nil
    }
    
    func testGetAuthEndpoint() {
        XCTAssertEqual(endpoints?.getAuthEndpoint(), Constants.authPart)
    }
    
    func testGetLogoutEndpoint() {
        XCTAssertEqual(endpoints?.getLogoutEndpoint(), Constants.logoutPart)
    }
    
    func testGetTokenEndpoint() {
        XCTAssertEqual(endpoints?.getTokenEndpoint(), Constants.endpointTokenPart)
    }
}
