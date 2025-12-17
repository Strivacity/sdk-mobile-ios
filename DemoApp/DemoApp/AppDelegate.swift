import StrivacitySDK
import SwiftUI

class AppDelegate: UIResponder, UIApplicationDelegate {
    let provider: AuthProvider

    override init() {
        guard
            let infoDictionary = Bundle.main.infoDictionary,
            let issuer = infoDictionary["ISSUER_URL"] as? String,
            !issuer.isEmpty,
            let redirect = infoDictionary["REDIRECT_URL"] as? String,
            !redirect.isEmpty,
            let postLogout = infoDictionary["POST_LOGOUT_REDIRECT_URL"]
                as? String,
            !postLogout.isEmpty,
            let clientId = infoDictionary["CLIENT_ID"] as? String,
            !clientId.isEmpty
        else {
            fatalError("There were missing configuration attributes")
        }

        let issuerUrl = URL(string: issuer.replacing("||", with: "//"))!
        let redirectUrl = URL(string: redirect.replacing("||", with: "//"))!
        let postLogoutUrl = URL(string: postLogout.replacing("||", with: "//"))!

        provider = AuthProvider.create(
            issuer: issuerUrl,
            redirectUri: redirectUrl,
            clientId: clientId,
            storage: CustomStorageImpl()
        )
        .withScopes(["profile", "email"])
        .withPostLogoutUri(postLogoutUrl)
    }

    func application(
        _: UIApplication,
        open url: URL,
        options _: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        provider.resumeExternalUserAgentFlow(url: url)
    }
}
