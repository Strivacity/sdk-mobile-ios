import AppAuthCore
import Foundation
import LocalAuthentication
import os
import StrivacitySDK

class CustomStorageImpl: Storage {
    private let KEY = "com.strivacity.sdk.AuthState"

    private let keychain: KeychainHelper
    private let context = LAContext()

    init(keychain: KeychainHelper = KeychainHelper()) {
        self.keychain = keychain
    }

    func clear() {
        log("clear storage")

        let query = [
            kSecAttrAccount: KEY,
            kSecClass: kSecClassGenericPassword,
        ] as [CFString: Any] as CFDictionary

        keychain.delete(query)
    }

    func setState(authState: OIDAuthState?) {
        log("save state in storage")
        if let authState = authState {
            log("authState is not nil")

            var data: Data
            do {
                data = try NSKeyedArchiver.archivedData(withRootObject: authState, requiringSecureCoding: true)
            } catch {
                log("failed to archive data")
                return
            }

            let query = [
                kSecValueData: data,
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: KEY,
                kSecAttrAccessControl: getBioSecAccessControl(),
            ] as CFDictionary

            let status = keychain.set(query)

            if status != errSecSuccess {
                if status == errSecDuplicateItem {
                    let updateQuery = [
                        kSecAttrAccount: KEY,
                        kSecClass: kSecClassGenericPassword,
                        kSecAttrAccessControl: getBioSecAccessControl(),
                    ] as CFDictionary

                    let attributeToUpdate = [kSecValueData: data] as CFDictionary

                    keychain.update(updateQuery, update: attributeToUpdate)
                } else {
                    log("error during saving authState, status: %{s}@", info: "\(status)")
                }
            }
        } else {
            log("authState is nil")
            clear()
        }
    }

    func getState() -> OIDAuthState? {
        log("get state from storage")

        let access = getBioSecAccessControl()

        let query = [
            kSecAttrAccount: KEY,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne,
            kSecUseAuthenticationContext: context,
            kSecAttrAccessControl: access,
            kSecUseAuthenticationUI: kSecUseAuthenticationUISkip,
        ] as [CFString: Any] as CFDictionary

        let semaphore = DispatchSemaphore(value: 0)
        var authSuccess = false
        var evaluationError: NSError?
        context
            .evaluateAccessControl(access, operation: .useItem, localizedReason: "Biometric login") { success, error in
                authSuccess = success
                evaluationError = error as NSError?
                semaphore.signal()
            }

        semaphore.wait()

        if authSuccess {
            let result = keychain.get(query)

            guard let result = result as? Data else {
                log("result is nil")
                return nil
            }

            guard let authState = try? NSKeyedUnarchiver.unarchivedObject(ofClass: OIDAuthState.self, from: result) else {
                log("failed to unarchive auth state")
                return nil
            }

            return authState
        }
        if let evaluationError = evaluationError {
            log("biometric error: ", info: evaluationError.localizedDescription)
        }
        return nil
    }

    private func getBioSecAccessControl() -> SecAccessControl {
        var access: SecAccessControl?
        var error: Unmanaged<CFError>?
        access = SecAccessControlCreateWithFlags(nil,
                                                 kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                                 .biometryCurrentSet,
                                                 &error)
        precondition(access != nil, "SecAccessControlCreateWithFlags failed")
        return access!
    }

    private func log(_ msg: StaticString) {
        os_log(msg, log: OSLog(subsystem: "com.strivacity.sdk", category: "sdk-debug"), type: .info)
    }

    private func log(_ msg: StaticString, info: String) {
        os_log(msg, log: OSLog(subsystem: "com.strivacity.sdk", category: "sdk-debug"), type: .info, info)
    }

    private func logAuthenticationError(error: NSError?) {
        if let error = error {
            switch error.code {
            case LAError.authenticationFailed.rawValue:
                log("Authentication failed: User failed to authenticate.")
            case LAError.userCancel.rawValue:
                log("Authentication canceled by the user.")
            case LAError.userFallback.rawValue:
                log("User tapped the fallback button (enter password).")
            case LAError.biometryNotAvailable.rawValue:
                log("Biometric authentication is not available on this device.")
            case LAError.biometryNotEnrolled.rawValue:
                log("No biometric enrollment: The user has not set up biometrics.")
            case LAError.biometryLockout.rawValue:
                log("Biometry lockout: Too many failed attempts.")
            default:
                log("Other authentication error:", info: error.localizedDescription)
            }
        }
    }
}

class KeychainHelper {
    func set(_ query: CFDictionary) -> OSStatus {
        return SecItemAdd(query, nil)
    }

    func update(_ query: CFDictionary, update: CFDictionary) {
        SecItemUpdate(query, update)
    }

    func delete(_ query: CFDictionary) {
        SecItemDelete(query)
    }

    func get(_ query: CFDictionary) -> AnyObject? {
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        return result
    }
}
