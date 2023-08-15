import UIKit
import StrivacitySDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    var authProvider: AuthProvider!
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        authProvider.resumeExternalUserAgentFlow(url: url)
    }
}
