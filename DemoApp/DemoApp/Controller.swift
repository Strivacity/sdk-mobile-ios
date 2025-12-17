import StrivacitySDK
import UIKit

class UIController: ObservableObject {
    @Published var errorText: String?
    @Published var accessToken: String?
    @Published var claims: [AnyHashable: Any]?
    @Published var additionalParams: [String: Any]?
    @Published var isAuthenticated = false

    let appDelegate: AppDelegate

    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
    }

    func startFlow(viewController: UIViewController,flowConfiguration: ((AuthProvider) -> Void)? = nil) {
        let additionalParams = ["customKey": "customValue"]
        flowConfiguration?(appDelegate.provider)
        appDelegate.provider
            .startFlow(
            viewController: viewController,
            refreshTokenAdditionalParameters: additionalParams
        ) { accessToken, claims in
            print("success")
            self.isAuthenticated = true
            self.errorText = nil
            self.accessToken = accessToken
            self.claims = claims
        } onError: { error in
            print("error")
            self.errorText = error.localizedDescription
            self.isAuthenticated = false
            self.accessToken = nil
            self.claims = nil
        }
    }

    func getAccessToken(additionalParams: [String: String] = [:]) {
        appDelegate.provider.getAccessToken(
            refreshTokenAdditionalParameters: additionalParams
        ) { accessToken in
            self.accessToken = accessToken
        } onError: { error in
            self.errorText = error.localizedDescription
        }
    }

    func getLastAdditionalParams() {
        additionalParams = appDelegate.provider
            .getLastTokenResponseAdditionalParameters()
    }

    func getClaims() {
        claims = appDelegate.provider.getLastRetrievedClaims()
    }

    func revoke() {
        appDelegate.provider.revoke { error in
            self.errorText = error?.localizedDescription
            self.isAuthenticated = false
        }
    }

    func logout(viewController: UIViewController) {
        appDelegate.provider.logout(viewController: viewController) { error in
            self.errorText = error?.localizedDescription
            self.isAuthenticated = false
        }
    }

    func checkAuthenticated() {
        let additionalParams = ["customKey": "customValue"]
        appDelegate.provider.checkAuthenticated(
            refreshTokenAdditionalParameters: additionalParams
        ) { isAuthenticated in
            self.isAuthenticated = isAuthenticated
        }
    }
}
