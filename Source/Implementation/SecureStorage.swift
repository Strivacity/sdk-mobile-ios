//
//  SecureStorage.swift
//  Strivacity
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Security
import AppAuth

/**
 * Specifies errors which can occur when work with Keychain.
 */
enum KeychainStoreError: Error {
    /// The item which is going to be stored is treated as duplicated
    case duplicatedItem
    /// Some error occured
    case unexpectedError
}

/**
 * Performs auth state storing inside iOS Keychain.
 */
class SecureStorage: ISecureStorage {
    /// key to store auth info
    private let key = "authinfo"
    /// stores current auth state
    private var currentAuthState: OIDAuthState?
    /// synchronises get/set operations
    private let secureStorageQueue = DispatchQueue(label: "com.strivacity.secureStorageQueue", attributes: .concurrent)
    
    /**
     * Performs auth state storing.
     *
     * - Parameters:
     *   - authInfo: The auth state to be stored.
     *   - completion: The callback to invoke upon storing completion.
     */
    func setAuthInfo(authInfo: AnyObject, completion: @escaping (Result<Bool, Error>) -> Void) {
        secureStorageQueue.sync(flags: .barrier, execute: {
            do {
                guard let authInfo = authInfo as? OIDAuthState else {
                    print("Failed to cast auth state.")
                    completion(.failure(KeychainStoreError.unexpectedError))
                    return
                }
                
                self.currentAuthState = authInfo
                let data = try NSKeyedArchiver.archivedData(withRootObject: authInfo, requiringSecureCoding: true)
                let query = [kSecClass as String       : kSecClassGenericPassword as String,
                             kSecAttrAccount as String : key,
                             kSecValueData as String   : data] as [String : Any]
                SecItemDelete(query as CFDictionary)
                SecItemAdd(query as CFDictionary, nil)
                
                var result: CFTypeRef?
                let status: OSStatus = SecItemAdd(query as CFDictionary, &result)
                
                if status == errSecSuccess {
                    completion(.success((true)))
                } else if status == errSecDuplicateItem {
                    completion(.failure(KeychainStoreError.duplicatedItem))
                } else if let error = result?.error, let _error = error {
                    completion(.failure(_error))
                } else {
                    completion(.failure(KeychainStoreError.unexpectedError))
                }
            } catch {
                print("Failed to save auth info into secure storage with error - \(error).")
                completion(.failure(KeychainStoreError.unexpectedError))
            }
        })
    }
    
    /**
     * Returns stored auth state.
     *
     * - Returns: Valid auth state object if the stored object is or nil if no one object is stored.
     */
    func getAuthInfo() -> AnyObject? {
        return secureStorageQueue.sync(flags: .barrier, execute: { () -> OIDAuthState? in
            if self.currentAuthState != nil {
                return self.currentAuthState
            }
            
            let query = [kSecClass as String       : kSecClassGenericPassword,
                         kSecAttrAccount as String : key,
                         kSecReturnData as String  : kCFBooleanTrue as CFBoolean,
                         kSecMatchLimit as String  : kSecMatchLimitOne] as [String : Any]
            var dataTypeRef: AnyObject? = nil
            let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
            
            guard let existedAuthInfo = dataTypeRef as? Data else {
                print("Failed to unwrap existed authentication info data.")
                return nil
            }
            
            if status != noErr {
                print("Failed to get authentication info with status: \(status).")
                return nil
            }
            
            do {
                let authState = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(existedAuthInfo)
                print("Unarchiving existed authentication info succeeded.")
                self.currentAuthState = authState as? OIDAuthState
                
                return self.currentAuthState
            } catch {
                print("Failed to unarchive existed authentication info with error: \(error)")
            }
            
            return nil
        })
    }
    
    /**
     * Removes stored auth state.
     *
     * - Parameter completion: The callback to invoke upon removal completion.
     */
    func removeAuthInfo(completion: @escaping (Result<Bool, Error>) -> Void) {
        secureStorageQueue.sync(flags: .barrier, execute: {
            let query = [kSecClass as String       : kSecClassGenericPassword as String,
                         kSecAttrAccount as String : key] as [String : Any]
            SecItemDelete(query as CFDictionary)
            
            SecItemDelete(query as CFDictionary) == errSecSuccess ? completion(.success((true))) : completion(.failure(KeychainStoreError.unexpectedError))
            self.currentAuthState = nil
        })
    }
}
