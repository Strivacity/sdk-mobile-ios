import StrivacitySDK
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    var authProvider: AuthProvider!

    func application(_: UIApplication, open url: URL, options _: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        authProvider.resumeExternalUserAgentFlow(url: url)
    }
}
