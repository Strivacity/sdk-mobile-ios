![Strivacity iOS SDK](https://static.strivacity.com/images/ios-native-sdk.png)

[View in Docs](https://docs.strivacity.com/docs/ios-mobile-sdk)

See our [Developer Portal](https://www.strivacity.com/learn-support/developer-hub) to get started with developing for the Strivacity product.

# Overview

This SDK allows you to integrate Strivacity’s policy-driven journeys into your brand’s iOS mobile application. It implements Strivacity's no-code components via iOS's [ASWebAuthenticationSession](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession) . 

This SDK uses <https://appauth.io>, which follows the best practices from [RFC 8252 - OAuth 2.0 for Native Apps](https://tools.ietf.org/html/rfc8252),  including using in-app browser views like ASWebAuthenticationSession. Embedded user-agents, known as web-views, are not supported due to usability and security reasons documented in [Section 8.12 of RFC 8252](https://tools.ietf.org/html/rfc8252#section-8.12).

The SDK uses the [PKCE extension to OAuth](https://tools.ietf.org/html/rfc7636) to ensure the secure exchange of authorization codes in public clients.

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

Note: urls won't work with '//' charachters, so refer to <https://stackoverflow.com/questions/21317844/how-do-i-configure-full-urls-in-xcconfig-files> ,  
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
    .withAcrValues()                    // for defining acr values
    .withUiLocales()                    // for defining ui locales
    .withPrompts()                      // for defining prompts
    .withPostLogoutUri()                // for defining redirect uri after logout
```

## Starting the flow

After a successful set up, you can use the startFlow method to initiate the login process.  
You have to provide the viewController and define the success and onError callbacks which is called from this method.

```swift
provider.startFlow(viewController: myViewController, additionalParameters: additionalParams) { accessToken, claims in
    // add success logic here
} onError: { error in
    // handle error
}
```

## Get access token

To obtain the access token you can use getAccessToken method to retrieve it from the auth state  
or the method tries to refresh it using refresh token. Access token can be nil.

```swift
provider.getAccessToken(additionalParameters: additionalParams) { accessToken in
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

## Get last token additional parameters

If you are using token refreshing to renew your access token, you have the possibility to create a token refresh hook in the Admin Console
and pass additional information from the hook back to the mobile next to the new tokens. To do this, just use the following code.

```swift
let additionalParams = provider.getLastTokenResponseAdditionalParameters()
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
provider.checkAuthenticated(additionalParameters: additionalParams) { isAuthenticated in
    // add some logic here
}
```

## Test

To run unit tests, simply click the play button in the test files using the integrated test runner.

For UI tests, open the TestApp folder as a project using the TestApp.xcodeproj file. First, run the Docker image from the TestAppUITests folder by executing `docker-compose up -d`. 
Then, run the UI tests by clicking the play button in the corresponding test file.

## Author

Strivacity: [opensource@strivacity.com](mailto:opensource@strivacity.com)

## License

Strivacity is available under the Apache License, Version 2.0. See the [LICENSE](./LICENSE) file for more info.

## Vulnerability Reporting

The [Guidelines for responsible disclosure](https://www.strivacity.com/report-a-security-issue) details the procedure for disclosing security issues.  
Please do not report security vulnerabilities on the public issue tracker.
