import AppAuth
import XCTest

@testable import StrivacitySDK

final class StorageImplTests: XCTestCase {
    private var storage: Storage!
    private var mockedKeychainHelper: MockKeychainHelper!
    private var saveableAuthState: OIDAuthState!

    private var expectation: XCTestExpectation!

    override func setUpWithError() throws {
        mockedKeychainHelper = MockKeychainHelper()
        storage = StorageImpl(keychain: mockedKeychainHelper)
        saveableAuthState = TestUtils.createAuthState(clientId: "client_id")
        expectation = XCTestExpectation()
    }

    func testGetState() {
        mockedKeychainHelper.getCallback = { query in
            XCTAssertEqual(
                NSString(string: "com.strivacity.sdk.AuthState"),
                TestUtils.getValueFromCFDictionary(query, key: kSecAttrAccount)
            )
            XCTAssertEqual(kSecClassGenericPassword, TestUtils.getValueFromCFDictionary(query, key: kSecClass))
            XCTAssertEqual(kSecMatchLimitOne, TestUtils.getValueFromCFDictionary(query, key: kSecMatchLimit))
            self.expectation.fulfill()

            return NSKeyedArchiver.archivedData(withRootObject: self.saveableAuthState!) as AnyObject
        }
        let authStateFromStorage = storage.getState()
        XCTAssertEqual("client_id", authStateFromStorage?.lastAuthorizationResponse.request.clientID)
        wait(for: [expectation])
    }

    func testGetStateReturnsNil() {
        mockedKeychainHelper.getCallback = { query in
            XCTAssertEqual(
                NSString(string: "com.strivacity.sdk.AuthState"),
                TestUtils.getValueFromCFDictionary(query, key: kSecAttrAccount)
            )
            XCTAssertEqual(kSecClassGenericPassword, TestUtils.getValueFromCFDictionary(query, key: kSecClass))
            XCTAssertEqual(kSecMatchLimitOne, TestUtils.getValueFromCFDictionary(query, key: kSecMatchLimit))
            self.expectation.fulfill()

            return nil
        }
        let authStateFromStorage = storage.getState()
        XCTAssertNil(authStateFromStorage)
        wait(for: [expectation])
    }

    func testGetStateReturnsNilDuringUnarchive() {
        mockedKeychainHelper.getCallback = { query in
            XCTAssertEqual(
                NSString(string: "com.strivacity.sdk.AuthState"),
                TestUtils.getValueFromCFDictionary(query, key: kSecAttrAccount)
            )
            XCTAssertEqual(kSecClassGenericPassword, TestUtils.getValueFromCFDictionary(query, key: kSecClass))
            XCTAssertEqual(kSecMatchLimitOne, TestUtils.getValueFromCFDictionary(query, key: kSecMatchLimit))
            self.expectation.fulfill()

            return NSObject()
        }
        let authStateFromStorage = storage.getState()
        XCTAssertNil(authStateFromStorage)
        wait(for: [expectation])
    }

    func testSetState() {
        mockedKeychainHelper.setCallback = { query in
            XCTAssertEqual(
                NSString(string: "com.strivacity.sdk.AuthState"),
                TestUtils.getValueFromCFDictionary(query, key: kSecAttrAccount)
            )
            XCTAssertEqual(kSecClassGenericPassword, TestUtils.getValueFromCFDictionary(query, key: kSecClass))

            let data = NSKeyedArchiver.archivedData(withRootObject: self.saveableAuthState!) as NSObject
            XCTAssertEqual(data, TestUtils.getValueFromCFDictionary(query, key: kSecValueData))

            self.expectation.fulfill()

            return errSecSuccess
        }
        storage.setState(authState: saveableAuthState)
        wait(for: [expectation])
    }

    func testSetStateDuplicateItem() {
        mockedKeychainHelper.setCallback = { query in
            XCTAssertEqual(
                NSString(string: "com.strivacity.sdk.AuthState"),
                TestUtils.getValueFromCFDictionary(query, key: kSecAttrAccount)
            )
            XCTAssertEqual(kSecClassGenericPassword, TestUtils.getValueFromCFDictionary(query, key: kSecClass))

            let data = NSKeyedArchiver.archivedData(withRootObject: self.saveableAuthState!) as NSObject
            XCTAssertEqual(data, TestUtils.getValueFromCFDictionary(query, key: kSecValueData))

            self.expectation.fulfill()

            return errSecDuplicateItem
        }
        mockedKeychainHelper.updateCallback = { query, update in
            XCTAssertEqual(
                NSString(string: "com.strivacity.sdk.AuthState"),
                TestUtils.getValueFromCFDictionary(query, key: kSecAttrAccount)
            )
            XCTAssertEqual(kSecClassGenericPassword, TestUtils.getValueFromCFDictionary(query, key: kSecClass))

            let data = NSKeyedArchiver.archivedData(withRootObject: self.saveableAuthState!) as NSObject
            XCTAssertEqual(data, TestUtils.getValueFromCFDictionary(update, key: kSecValueData))

            self.expectation.fulfill()
        }
        storage.setState(authState: saveableAuthState)
        wait(for: [expectation])
    }

    func testSetStateNilValue() {
        mockedKeychainHelper.deleteCallback = { query in
            XCTAssertEqual(
                NSString(string: "com.strivacity.sdk.AuthState"),
                TestUtils.getValueFromCFDictionary(query, key: kSecAttrAccount)
            )
            XCTAssertEqual(kSecClassGenericPassword, TestUtils.getValueFromCFDictionary(query, key: kSecClass))
            self.expectation.fulfill()
        }
        storage.setState(authState: nil)
        wait(for: [expectation])
    }

    func testClearState() {
        mockedKeychainHelper.deleteCallback = { query in
            XCTAssertEqual(
                NSString(string: "com.strivacity.sdk.AuthState"),
                TestUtils.getValueFromCFDictionary(query, key: kSecAttrAccount)
            )
            XCTAssertEqual(kSecClassGenericPassword, TestUtils.getValueFromCFDictionary(query, key: kSecClass))
            self.expectation.fulfill()
        }
        storage.clear()
        wait(for: [expectation])
    }
}
