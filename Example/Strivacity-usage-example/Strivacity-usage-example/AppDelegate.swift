//
//  AppDelegate.swift
//  Strivacity-usage-example
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import UIKit
import Strivacity

@main
class AppDelegate: UIResponder, UIApplicationDelegate, IProviderCallback {
    private var authClient: IAuthClient?
    private let clientIdKey = "Strivacity id"
    private let clientSecretKey = "Strivacity secret"
    private let domainKey = "Strivacity domain"
    private let redirectUriKey = "Strivacity redirect uri"
    private var authClientCreationError: NSError?
    private static var firstTime = true
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let url = launchOptions?[UIApplication.LaunchOptionsKey.url]
        print(url ?? "")
        NotificationCenter.default.addObserver(self, selector: #selector(self.appDidBecomeActive(notification:)), name: Notification.Name("didBecomeActiveNotification"), object: nil)
        
        let authProvider = AuthProvider()
            .withClientId(Bundle.main.object(forInfoDictionaryKey: clientIdKey) as? String ?? "") // specifies app client id
            .withClientSecret(Bundle.main.object(forInfoDictionaryKey: clientSecretKey) as? String ?? "") // specifies app client secret
            .withDomain(Bundle.main.object(forInfoDictionaryKey: domainKey) as? String ?? "") // specifies authentication server domain
            .withRedirectUri(Bundle.main.object(forInfoDictionaryKey: redirectUriKey) as? String ?? "") // specifies authorized redirect uri
            .setUseSecureStorage(true) // specifies using SecureStorage for saving auth state between app launches
            .setUseBiometric(EBiometricType.any) // specifies biometric usage
        authProvider.provide(self)
        
        return true
    }
    
    @objc func appDidBecomeActive(notification: Notification) {
        if !AppDelegate.firstTime {
            return
        }
        
        AppDelegate.firstTime = false
        if let client = authClient {
            if let rootViewController = UIApplication.shared.windows.first?.rootViewController as? IAuthClientSetter {
                rootViewController.setAuthClient(client)
            }
        } else if let error = authClientCreationError {
            let alert = UIAlertController(title: "Biometric authentication error", message: "Failed to perform biometric authentication, \(error.localizedDescription)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in }))
            
            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
        }
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return authClient?.proceedExternalUserAgentFlow(with: url) ?? false
    }
    
    // MARK: IProviderCallback methods
    func onSuccess(authClient: AuthClient) {
        self.authClient = authClient
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController as? IAuthClientSetter {
            rootViewController.setAuthClient(authClient)
        }
    }
    
    func onError(error: NSError) {
        self.authClientCreationError = error
    }
}
