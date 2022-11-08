//
//  UrlFactoryTests.swift
//  StrivacityTests
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation
import XCTest
@testable import Strivacity

final class UrlFactoryTests: XCTestCase {
    var urlFactory: IUrlFactory?
    
    override func setUp() {
        urlFactory = UrlFactory(Endpoints())
    }
    
    override func tearDown() {
        urlFactory = nil
    }
    
    func testGetAuthServerHostSuccess() {
        let authHost = urlFactory?.getAuthServerHost(for: TestConstants.testDomain)
        XCTAssertEqual(authHost, URL(string: TestConstants.testDomain + Constants.authPart))
    }
    
    func testGetAuthServerHostWrongDomain() {
        let authHost = urlFactory?.getAuthServerHost(for: TestConstants.wrongDomain)
        XCTAssertNotEqual(authHost, URL(string: TestConstants.testDomain + Constants.authPart))
    }
    
    func testGetLogoutUrlWithHttpsSuccess() {
        let logoutUrl = urlFactory?.getLogoutUrl(for: TestConstants.testDomain, shouldAddHttpsPrefix: true)
        XCTAssertEqual(logoutUrl, URL(string: Constants.httpsPrefix + TestConstants.testDomain + Constants.logoutPart))
    }
    
    func testGetLogoutUrlWithoutHttpsSuccess() {
        let logoutUrl = urlFactory?.getLogoutUrl(for: TestConstants.testDomain, shouldAddHttpsPrefix: false)
        XCTAssertEqual(logoutUrl, URL(string: TestConstants.testDomain + Constants.logoutPart))
    }
    
    func testGetTokenRequestUrlSuccess() {
        let tokenRequestUrl = urlFactory?.getTokenRequestUrl(for: TestConstants.testDomain)
        XCTAssertEqual(tokenRequestUrl, URL(string: TestConstants.testDomain + Constants.endpointTokenPart))
    }
}
