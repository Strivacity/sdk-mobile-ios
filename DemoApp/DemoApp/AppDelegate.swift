import SwiftUI
import StrivacitySDK

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let provider: AuthProvider
    
    override init() {
        guard
            let infoDictionary = Bundle.main.infoDictionary,
            let issuer = infoDictionary["ISSUER_URL"] as? String,
            !issuer.isEmpty,
            let redirect = infoDictionary["REDIRECT_URL"] as? String,
            !redirect.isEmpty,
            let postLogout = infoDictionary["POST_LOGOUT_REDIRECT_URL"] as? String,
            !postLogout.isEmpty,
            let clientId = infoDictionary["CLIENT_ID"] as? String,
            !clientId.isEmpty
        else {
            fatalError("There were missing configuration attributes")
        }
        
        provider = AuthProvider.create(
            issuer: URL(string: issuer)!,
            redirectUri: URL(string: redirect)!,
            clientId: clientId,
            storage: nil
        )
        .withScopes(["profile", "email"])
        .withPostLogoutUri(URL(string: postLogout)!)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        provider.resumeExternalUserAgentFlow(url: url)
    }
}
