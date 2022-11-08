//
//  SecureStorageTests.swift
//  StrivacityTests
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation
import XCTest
@testable import Strivacity

final class SecureStorageTest: XCTestCase {
    var secureStorage: SecureStorage?
    
    override func setUp() {
        secureStorage = SecureStorage()
    }
    
    override func tearDown() {
        secureStorage?.removeAuthInfo( completion: { result in
            switch result {
            case .success(let isDelete):
                XCTAssertEqual(isDelete, true)
                break
            case .failure(let error):
                XCTAssertEqual(error as? KeychainStoreError, KeychainStoreError.unexpectedError)
                break
            }
        })
        secureStorage = nil
    }
    
    func testIsNotNil() {
        XCTAssertNotNil(secureStorage)
    }
    
    func testSuccessGetData() {
        secureStorage?.setAuthInfo(authInfo: AuthClientData.createAuthState(), completion: { result in
            switch result {
            case .success(let isLogin):
                XCTAssertEqual(isLogin, true)
                break
            case .failure(let error):
                XCTAssertEqual(error as? KeychainStoreError, KeychainStoreError.unexpectedError)
                break
            }
        })
        
        let authState = secureStorage?.getAuthInfo()
        XCTAssertNotNil(authState)
    }
    
    func testFailGetData() {
        let authState = secureStorage?.getAuthInfo()
        XCTAssertNil(authState)
    }
    
    func testSuccessSaveData() {
        secureStorage?.setAuthInfo(authInfo: AuthClientData.createAuthState(), completion: { result in
            switch result {
            case .success(let isLogin):
                XCTAssertEqual(isLogin, true)
                break
            case .failure(let error):
                XCTAssertEqual(error as? KeychainStoreError, KeychainStoreError.unexpectedError)
                break
            }
        })
    }
    
    func testFailSaveData() {
        var expectedError: KeychainStoreError?
        secureStorage?.setAuthInfo(authInfo: TestObject(), completion: { result in
            switch result {
            case .success(_):
                expectedError = nil
                break
            case .failure(let error):
                expectedError = error as? KeychainStoreError
                break
            }
        })
        
        XCTAssertEqual(expectedError, KeychainStoreError.unexpectedError)
    }
    
    func testSuccessDeleteData() {
        secureStorage?.removeAuthInfo( completion: { result in
            switch result {
            case .success(let isDelete):
                XCTAssertEqual(isDelete, true)
                break
            case .failure(let error):
                XCTAssertEqual(error as? KeychainStoreError, KeychainStoreError.unexpectedError)
                break
            }
        })
    }
}

