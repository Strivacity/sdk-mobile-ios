//
//  AuthProvider.swift
//  Strivacity
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation
import AppAuth
import LocalAuthentication

/**
 * Specifies the biometric authentication usage in Strivacity SDK.
 */
public enum EBiometricType {
    
    /// Specifies that biometric authentication is not used
    case none
    
    /// Specifies that biometric authentication is used
    case any
}

/**
 * Uses for initialization [AuthClient] object
 */
public class AuthProvider {
    private var config: Config
    private var enableSecureStorage: Bool
    private var authState: OIDAuthState?
    private var biometricManager: IBiometricManager?
    private var biometricType: EBiometricType
    
    /**
     * Initialises [AuthProvider] members with default values.
     */
    public init() {
        config = Config(clientId: "", clientSecret: "", domain: "", redirectUri: "")
        enableSecureStorage = true
        biometricType = .none
    }
    
    /**
     * Specifies client id for [AuthClient]
     *
     * - Parameter clientId: specifies client id.
     *
     * - Returns: AuthProvider object is returned.
     */
    public func withClientId(_ clientId: String) -> AuthProvider {
        self.config.clientId = clientId
        return self
    }
    
    /**
     * Specifies client secret for [AuthClient]
     *
     * - Parameter clientSecret: specifies client secret.
     *
     * - Returns: AuthProvider object is returned.
     */
    public func withClientSecret(_ clientSecret: String) -> AuthProvider {
        self.config.clientSecret = clientSecret
        return self
    }
    
    /**
     * Specifies domain for [AuthClient]
     *
     * - Parameter domain: specifies domain.
     *
     * - Returns: AuthProvider object is returned.
     */
    public func withDomain(_ domain: String) -> AuthProvider {
        self.config.domain = domain
        return self
    }
    
    /**
     * Specifies redirect uri for [AuthClient]
     *
     * - Parameter redirectUri: specifies redirect uri.
     *
     * - Returns: AuthProvider object is returned.
     */
    public func withRedirectUri(_ redirectUri: String) -> AuthProvider {
        self.config.redirectUri = redirectUri
        return self
    }
    
    /**
     * Specifies using [SecureStorage]
     *
     * - Parameter enabled: specifies secure storage usage.
     *
     * - Returns: AuthProvider object is returned.
     */
    public func setUseSecureStorage(_ enabled: Bool) -> AuthProvider  {
        self.enableSecureStorage = enabled
        return self
    }
    
    /**
     * Specifies initial [AuthState]
     *
     * - Parameter authState: initial auth state.
     *
     * - Returns: AuthProvider object is returned.
     */
    public func withAuthState(_ authState: OIDAuthState) -> AuthProvider {
        self.authState = authState
        return self
    }
    
    /**
    Specifies parameters for biometric authentication.
     
      - Parameters:
        - biometricType: The type of biometric sensor. If biometricType is [BiometricType.ANY],
       then the biometric user authentication will be required. If biometricType is [BiometricType.NO],
       the biometric user authentication will not be required;
        - biometricManager: The particular class which implements [IBiometricManager] protocol
    and handles biometric authentication inside. If no one value for this parameter is specified or nill
    is passed, then the [BiometricManager] class with default context will be instantiated.
     
      - Returns: AuthProvider object is returned.
     */
    public func setUseBiometric(_ biometricType: EBiometricType, _ biometricManager: IBiometricManager? = nil) -> AuthProvider {
        self.biometricType = biometricType
        if biometricType == .any {
            self.biometricManager = biometricManager == nil ? BiometricManager(context: LAContext()) : biometricManager
        } else {
            self.biometricManager = nil
        }
        
        return self
    }
    
    /**
     * Creates [AuthClient] with provided options.
     *
     * - Parameter providerCallback: The callback to invoke after AuthClient creation,
     * it takes [AuthClient] object on success or [APIError] object on failure.
     */
    public func provide(_ providerCallback: IProviderCallback) {
        switch(biometricType) {
        case .none:
            let authClient = createAuthClient()
            providerCallback.onSuccess(authClient: authClient)
            break
        case .any:
            guard let biometricManager = biometricManager else {
                providerCallback.onError(error: APIError.biometricManagerCreationFailure as NSError)
                return
            }
            
            if !biometricManager.isBiometricSupported() {
                providerCallback.onError(error: APIError.biometricIsNotSupportedError as NSError)
                break
            }
            
            biometricManager.authenticate { authenticationResult in
                if authenticationResult {
                    let authClient = self.createAuthClient()
                    providerCallback.onSuccess(authClient: authClient)
                } else {
                    providerCallback.onError(error: APIError.biometricAuthenticationError as NSError)
                }
            }
            break
        }
    }
    
    /**
     * Checks that the device supports biometric authentication.
     *
     * - Returns: Boolean result, true if the biometric authentication supported, false otherwise.
     */
    public func isBiometricSupported() -> Bool {
        biometricManager?.isBiometricSupported() ?? false
    }
    
    /**
     * Creates [AuthClient] with provided options.
     *
     * - Returns: AuthClient object.
     */
    private func createAuthClient() -> AuthClient {
        AuthClient(config: config, authState: authState, secureStorage: enableSecureStorage ? SecureStorage() : nil)
    }
}
