# Strivacity SDK for iOS

This SDK allows you to integrate Strivacity's sign-in journeys
into your brand's iOS mobile applications.
The SDK uses OAuth 2.0 PKCE flow to communicate with Strivacity.

## How to use

To use the Strivacity iOS SDK:

If you are using [Swift Package Manager](https://www.swift.org/package-manager/) extend your `Package.swift` file with the following dependency

```swift
.package(url: "https://github.com/Strivacity/sdk-mobile-ios.git", from: "<version>")
```
where `<version>` is the SDK version you want to use.

If you are using an XCode Project use the `File / Add Packages...` option enter the following url: `https://github.com/Strivacity/sdk-mobile-ios.git` and select the `sdk-mobile-ios` package with the version you want to use

## Demo App

A demo app is part of this repository.

### Before using demo app

Create a Config.xcconfig file into DemoApp folder and copy the following:

```text
ISSUER_URL = 
CLIENT_ID = 
REDIRECT_URL = 
POST_LOGOUT_REDIRECT_URL = 
```

Note: urls won't work with '//' charachters, so refer to https://stackoverflow.com/questions/21317844/how-do-i-configure-full-urls-in-xcconfig-files ,
you have to put a '$()' between '//' (e.g.: '/$()/').

Before you start the app, don't forget to set the config file in the app settings: Project -> Info -> Configurations.

## Overview

Note: The internal implementation of the Strivacity SDK for iOS relies on the open source [AppAuth Library](https://github.com/openid/AppAuth-iOS).

Strivacity SDK for iOS provides the possibility to build an application which can communicate with Strivacity using OAuth 2.0 PKCE flow.
You can define your own storage logic using the [Storage](https://github.com/Strivacity/sdk-mobile-ios/blob/main/Sources/StrivacitySDK/Storage.swift) interface.
Refresh token can be used to refresh the auth state instead of running authentication again.

## Initialize AuthProvider

First, you must call the AuthProvider create method to create an instance:
```swift
let provider = AuthProvider.create(
    issuer,                                      // specifies authentication server domain
    redirectUri,                                 // specifies the redirect uri
    clientId,                                    // specifies OAuth client ID
    storage                                      // optional, you can provide the storage logic you implemented using Storage interface, or use the default unsecure storage logic
)
```

### Define more configurations

After you created the provider instance you can add more configs to fit your flow.
```swift
provider
    .withScopes()                       // for defining scopes (openid, offline is included by default)
    .withLoginHint()                    // for defining login hint
    .withPrompts()                      // for defining prompts
    .withPostLogoutUri()                // for defining redirect uri after logout
```

## Starting the flow

After a successful set up, you can use the startFlow method to initiate the login process.
You have to provide the viewController and define the success and onError callbacks which is called from this method.

```swift
provider.startFlow(viewController: myViewController) { accessToken, claims in
    // add success logic here
} onError: { error in
    // handle error
}
```

## Get access token

To obtain the access token you can use getAccessToken method to retrieve it from the auth state
or the method tries to refresh it using refresh token. Access token can be nil.

```swift
provider.getAccessToken { accessToken in
    // add success logic here
} onError: { error in
    // handle error
}
```

## Get claims

You have the possibility to get the claims from the last id token response (if it exists).
For this, call the getLastRetrievedClaims method which returns an '[AnyHashable: Any]?' object that contains the claims.
If there wasn't any claim, nil returns.

```swift
let claims = provider.getLastRetrievedClaims()
```

## Perform logout

After the logout, callback function is called both on success or failure logout. If there was no
auth state then it is removed from the storage. If an error happens, then the error will return.
You have to provide the viewController and the callback.

```swift
provider.logout(viewController: myViewController) { error in
    // add success logic and handle error if presents
}
```

## Checking authState is authenticated

There is a method where you can check if the auth state stored in the storage is authenticated or not.

```swift
provider.checkAuthenticated { isAuthenticated in
    // add some logic here
}
```

## Author

Strivacity <opensource@strivacity.com>

## License

Strivacity is available under the Apache License, Version 2.0. See the [LICENSE](./LICENSE) file for more info.

## Vulnerability Reporting

The [Guidelines for responsible disclosure](https://www.strivacity.com/report-a-security-issue) details the procedure for disclosing security issues.
Please do not report security vulnerabilities on the public issue tracker.