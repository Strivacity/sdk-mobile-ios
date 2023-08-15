import XCTest
import AppAuth

@testable import StrivacitySDK

final class AuthStateManagerTests: XCTestCase {
    
    private var authStateManager: AuthStateManager!
    private var authState: OIDAuthState!
    private var mockKeychainHelper: MockKeychainHelper!
    
    private var expectation: XCTestExpectation!
    
    override func setUpWithError() throws {
        mockKeychainHelper = MockKeychainHelper()
        authStateManager = AuthStateManager(storage: StorageImpl(keychain: mockKeychainHelper))
        authState = TestUtils.createAuthState(clientId: "client_id")
        expectation = XCTestExpectation()
    }
    
    func testGetCurrentStateFromStorage() {
        mockKeychainHelper.getCallback = { query in
            XCTAssertEqual(NSString(string: "com.strivacity.sdk.AuthState"), TestUtils.getValueFromCFDictionary(query, key: kSecAttrAccount))
            XCTAssertEqual(kSecClassGenericPassword, TestUtils.getValueFromCFDictionary(query, key: kSecClass))
            XCTAssertEqual(kSecMatchLimitOne, TestUtils.getValueFromCFDictionary(query, key: kSecMatchLimit))
            self.expectation.fulfill()
            
            return NSKeyedArchiver.archivedData(withRootObject: self.authState!) as AnyObject
        }
        
        let currentState = authStateManager.getCurrentState()
        XCTAssertEqual("client_id", currentState?.lastAuthorizationResponse.request.clientID)
        wait(for: [expectation])
    }
    
    func testGetCurrentState() {
        expectation.expectedFulfillmentCount = 1
        mockKeychainHelper.getCallback = { query in
            XCTAssertEqual(NSString(string: "com.strivacity.sdk.AuthState"), TestUtils.getValueFromCFDictionary(query, key: kSecAttrAccount))
            XCTAssertEqual(kSecClassGenericPassword, TestUtils.getValueFromCFDictionary(query, key: kSecClass))
            XCTAssertEqual(kSecMatchLimitOne, TestUtils.getValueFromCFDictionary(query, key: kSecMatchLimit))
            self.expectation.fulfill()
            
            return NSKeyedArchiver.archivedData(withRootObject: self.authState!) as AnyObject
        }
        
        var currentState = authStateManager.getCurrentState()
        XCTAssertEqual("client_id", currentState?.lastAuthorizationResponse.request.clientID)
        
        currentState = authStateManager.getCurrentState()
        XCTAssertEqual("client_id", currentState?.lastAuthorizationResponse.request.clientID)
        wait(for: [expectation])
    }
    
    func testSetCurrentState() {
        mockKeychainHelper.setCallback = { query in
            XCTAssertEqual(NSString(string: "com.strivacity.sdk.AuthState"), TestUtils.getValueFromCFDictionary(query, key: kSecAttrAccount))
            XCTAssertEqual(kSecClassGenericPassword, TestUtils.getValueFromCFDictionary(query, key: kSecClass))
            
            let data = NSKeyedArchiver.archivedData(withRootObject: self.authState!) as NSObject
            XCTAssertEqual(data, TestUtils.getValueFromCFDictionary(query, key: kSecValueData))
            
            self.expectation.fulfill()
            
            return errSecSuccess
        }
        authStateManager.setCurrentState(state: authState)
        
        let currentState = authStateManager.getCurrentState()
        XCTAssertEqual("client_id", currentState?.lastAuthorizationResponse.request.clientID)
        wait(for: [expectation])
    }
    
    func testSetCurrentStateWithNil() {
        expectation.expectedFulfillmentCount = 2
        mockKeychainHelper.deleteCallback = { query in
            XCTAssertEqual(NSString(string: "com.strivacity.sdk.AuthState"), TestUtils.getValueFromCFDictionary(query, key: kSecAttrAccount))
            XCTAssertEqual(kSecClassGenericPassword, TestUtils.getValueFromCFDictionary(query, key: kSecClass))
            self.expectation.fulfill()
        }
        mockKeychainHelper.getCallback = { query in
            XCTAssertEqual(NSString(string: "com.strivacity.sdk.AuthState"), TestUtils.getValueFromCFDictionary(query, key: kSecAttrAccount))
            XCTAssertEqual(kSecClassGenericPassword, TestUtils.getValueFromCFDictionary(query, key: kSecClass))
            XCTAssertEqual(kSecMatchLimitOne, TestUtils.getValueFromCFDictionary(query, key: kSecMatchLimit))
            self.expectation.fulfill()
            
            return NSKeyedArchiver.archivedData(withRootObject: self.authState!) as AnyObject
        }
        
        authStateManager.setCurrentState(state: nil)
        
        let currentState = authStateManager.getCurrentState()
        XCTAssertEqual("client_id", currentState?.lastAuthorizationResponse.request.clientID)
        wait(for: [expectation])
    }
    
    func testResetCurrentState() {
        expectation.expectedFulfillmentCount = 2
        mockKeychainHelper.deleteCallback = { query in
            XCTAssertEqual(NSString(string: "com.strivacity.sdk.AuthState"), TestUtils.getValueFromCFDictionary(query, key: kSecAttrAccount))
            XCTAssertEqual(kSecClassGenericPassword, TestUtils.getValueFromCFDictionary(query, key: kSecClass))
            self.expectation.fulfill()
        }
        mockKeychainHelper.getCallback = { query in
            XCTAssertEqual(NSString(string: "com.strivacity.sdk.AuthState"), TestUtils.getValueFromCFDictionary(query, key: kSecAttrAccount))
            XCTAssertEqual(kSecClassGenericPassword, TestUtils.getValueFromCFDictionary(query, key: kSecClass))
            XCTAssertEqual(kSecMatchLimitOne, TestUtils.getValueFromCFDictionary(query, key: kSecMatchLimit))
            self.expectation.fulfill()
            
            return NSKeyedArchiver.archivedData(withRootObject: self.authState!) as AnyObject
        }
        
        authStateManager.resetCurrentState()
        
        let currentState = authStateManager.getCurrentState()
        XCTAssertEqual("client_id", currentState?.lastAuthorizationResponse.request.clientID)
        wait(for: [expectation])
    }
}
