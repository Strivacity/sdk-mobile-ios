# Strivacity SDK for iOS

The Strivacity SDK for iOS provides a simple client for communicating with [Strivacity Authentication APIs](https://api.strivacity.com/reference/obtain-an-access-token-via-client-credentials)


## Download

Strivacity SDK for iOS is available through the [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your `Podfile`:

```ruby
pod 'Strivacity'
```


## Demo App

A demo app is contained within this repository. For instructions on how to build and configure this app, see its ReadMe file.


## Overview

Note: The internal implementation of the Strivacity SDK for iOS relies on the open source [AppAuth Library](https://github.com/openid/AppAuth-iOS).
Strivacity SDK encapsulates logic of communication with [Strivacity Authentication APIs](https://api.strivacity.com/reference/obtain-an-access-token-via-client-credentials) in the [AuthClient](/Source/Implementation/AuthClient.swift) class and its members. [AuthProvider](/Source/Implementation/AuthProvider.swift) class creates [AuthClient](/Source/Implementation/AuthClient.swift) and sets it up with specified parameters.
For a convenient representation of the authorization state with the ability to serialization to json uses class [AuthState](/Source/Implementation/AuthState.swift) from [AppAuth Library](https://github.com/openid/AppAuth-iOS).
To store the authentication state securely, use the class SecureStorage, which saves auth state to the default iOS [Keychain](https://developer.apple.com/documentation/security/keychain_services).


## Initialize AuthProvider

First, you must specify the [AuthProvider](/Source/Implementation/AuthProvider.swift) class to create an [AuthClient](/Source/Implementation/AuthClient.swift) instance. For example:
```swift
let authProvider = AuthProvider()

authProvider.withClientId(Bundle.main.object(forInfoDictionaryKey: clientIdKey) as? String ?? "") // specifies app client id
authProvider.withClientSecret(Bundle.main.object(forInfoDictionaryKey: clientSecretKey) as? String ?? "") // specifies app client secret
authProvider.withDomain(Bundle.main.object(forInfoDictionaryKey: domainKey) as? String ?? "") // specifies authentication server domain
authProvider.withRedirectUri(Bundle.main.object(forInfoDictionaryKey: redirectUriKey) as? String ?? "") // specifies authorized redirect uri
authProvider.withAuthState(authState) // specifies default auth state
authProvider.setUseSecureStorage(true) // specifies using SecureStorage for saving auth state between app launches
authProvider.setUseBiometric(EBiometricType.any) // specifies biometric usage
```

### Features of initialization:

- In order to initialize an `AuthClient` object with a particular `AuthState`, pass it to the `AuthProvider` object. 
```swift
    authProvider.withAuthState(authState) // specifies default auth state
```

In other cases, do not call this command. 

- Also the default iOS Keychain usage by `AuthClient` can be specified:
```swift
    authProvider.setUseSecureStorage(true) // specifies SecureStorage usage for saving auth state between app launches
```
In order to avoid storing auth state in Keychain, please pass `false` to this method.

- Biometric verification for accessing data in SecureStorage also can be specified:
```swift
    authProvider.setUseBiometric(EBiometricType.any) // specifies biometric usage
```
To disable biometric authentication, please pass `EBiometricType.none` to this method.


## Provide AuthClient

To obtain the AuthClient instance, you need to call the `authProvider.provide()` method with an object that has implemented the `IProviderCallback` interface methods.
```swift
public protocol IProviderCallback {
    /**
     * Invoked after successful [AuthClient] creation.
     */
    func onSuccess(authClient: AuthClient)
    
    /**
     * Invoked after completion with error of the [AuthClient] creation.
     */
    func onError(error: NSError)
}
```

## Examples of performing Strivacity Authentication APIs via AuthClient:

- Begin an OIDC Authorization Code Flow:
```swift
authClient.authorizeAuthCodeFlow(viewController: self, completion: { result in
    // result has type Result<AnyObject, Error> and can have AuthState object with auth code on success or Error on failure
})
```

- Obtain an ID Token from an Authorization Code which has been previously obtained via the Authorization Code Flow:
```swift
authClient.requestIdToken(viewController: self, completion: { result in
    // result has type Result<AnyObject, Error> and can have AuthState object with auth code, access token and id token on success or Error on failure
})
```

- Begin an OIDC Hybrid Flow:
```swift
authClient.authorizeHybridFlow(viewController: self, completion: { result in
    // result has type Result<AnyObject, Error> and can have AuthState object with auth code, access token and id token on success or Error on failure
})
```

- Begin an OIDC RP Initiated Logout:
```swift
authClient.logout(viewController: self, completion: logoutCompletion(_:))
//  logoutCompletion function has the argument of type Result<Bool, Error> and can have Boolean value on success or Error on failure
```

- Obtain an Access Token via Client Credentials:
```swift
authClient.requestAccessToken(viewController: self, completion: { result in
    // result has type Result<AnyObject, Error> and can have AuthState object with access token on success or Error on failure
})
```


## Author

Strivacity <opensource@strivacity.com>


## License

Strivacity is available under the Apache License, Version 2.0. See the [LICENSE](./LICENSE) file for more info.
