import AppAuth
import StrivacitySDK
import UIKit

class ViewController: UIViewController {
    private let DOMAIN_URL = URL(string: "http://localhost:8080/default")!
    private let REDIRECT_URL = URL(string: "com.strivacity.sdk.testapp://localhost:8080/default/oauth2redirect")!

    private let EXPIRY_DOMAIN_URL = URL(string: "http://localhost:8080/expiry")!
    private let EXPIRY_REDIRECT_URL = URL(string: "com.strivacity.sdk.testapp://localhost:8080/expiry/oauth2redirect")!

    private let NO_ACCESS_TOKEN = "No access token"
    private let NO_CLAIMS = "No claims"
    private let NO_ERROR = "No error"

    @IBOutlet var accessTokenL: UILabel!
    @IBOutlet var claimsL: UILabel!
    @IBOutlet var errorL: UILabel!
    @IBOutlet var isAuthenticatedL: UILabel!

    private let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBAction func startFlowSuccess() {
        createProvider(issuer: DOMAIN_URL, redirectURL: REDIRECT_URL)
            .startFlow(viewController: self) { accessToken, claims in
                self.accessTokenL.text = accessToken
                self.claimsL.text = claims?.description
                self.errorL.text = self.NO_ERROR
            } onError: { error in
                self.accessTokenL.text = self.NO_ACCESS_TOKEN
                self.claimsL.text = self.NO_CLAIMS
                self.errorL.text = error.localizedDescription
            }
    }

    @IBAction func startFlowWrongDomain() {
        createProvider(issuer: URL(string: "http://example.com")!, redirectURL: REDIRECT_URL)
            .startFlow(viewController: self) { accessToken, claims in
                self.accessTokenL.text = accessToken
                self.claimsL.text = claims?.description
                self.errorL.text = self.NO_ERROR
            } onError: { error in
                self.accessTokenL.text = self.NO_ACCESS_TOKEN
                self.claimsL.text = self.NO_CLAIMS
                self.errorL.text = error.localizedDescription
            }
    }

    @IBAction func getAccessTokenSuccess() {
        let provider = createProvider(issuer: DOMAIN_URL, redirectURL: REDIRECT_URL)
        provider.startFlow(viewController: self) { _, _ in
            provider.getAccessToken { accessToken in
                self.accessTokenL.text = accessToken
                self.claimsL.text = self.NO_CLAIMS
                self.errorL.text = self.NO_ERROR
            } onError: { error in
                self.accessTokenL.text = self.NO_ACCESS_TOKEN
                self.claimsL.text = self.NO_CLAIMS
                self.errorL.text = error.localizedDescription
            }
        } onError: { error in
            self.accessTokenL.text = self.NO_ACCESS_TOKEN
            self.claimsL.text = self.NO_CLAIMS
            self.errorL.text = error.localizedDescription
        }
    }

    @IBAction func getAccessTokenUsingRefreshToken() {
        let provider = createProvider(issuer: EXPIRY_DOMAIN_URL, redirectURL: EXPIRY_REDIRECT_URL)
        provider.startFlow(viewController: self) { accessToken, _ in
            // NOTE: wait until access token is expired
            Thread.sleep(forTimeInterval: 2)

            provider.getAccessToken { refreshedAccessToken in
                if accessToken != refreshedAccessToken {
                    self.accessTokenL.text = refreshedAccessToken
                } else {
                    self.accessTokenL.text = self.NO_ACCESS_TOKEN
                }
                self.claimsL.text = self.NO_CLAIMS
                self.errorL.text = self.NO_ERROR
            } onError: { error in
                self.accessTokenL.text = self.NO_ACCESS_TOKEN
                self.claimsL.text = self.NO_CLAIMS
                self.errorL.text = error.localizedDescription
            }
        } onError: { error in
            self.accessTokenL.text = self.NO_ACCESS_TOKEN
            self.claimsL.text = self.NO_CLAIMS
            self.errorL.text = error.localizedDescription
        }
    }

    @IBAction func getAccessTokenReturnsError() {
        createProvider(issuer: DOMAIN_URL, redirectURL: REDIRECT_URL)
            .getAccessToken { accessToken in
                self.accessTokenL.text = accessToken
                self.claimsL.text = self.NO_CLAIMS
                self.errorL.text = self.NO_ERROR
            } onError: { error in
                self.accessTokenL.text = self.NO_ACCESS_TOKEN
                self.claimsL.text = self.NO_CLAIMS
                self.errorL.text = error.localizedDescription
            }
    }

    @IBAction func getLastRetrievedClaimsSuccess() {
        let provider = createProvider(issuer: DOMAIN_URL, redirectURL: REDIRECT_URL)
        provider.startFlow(viewController: self) { _, _ in
            let claimsFromMethod = provider.getLastRetrievedClaims()

            self.accessTokenL.text = self.NO_ACCESS_TOKEN
            self.claimsL.text = claimsFromMethod?.description
            self.errorL.text = self.NO_ERROR
        } onError: { error in
            self.accessTokenL.text = self.NO_ACCESS_TOKEN
            self.claimsL.text = self.NO_CLAIMS
            self.errorL.text = error.localizedDescription
        }
    }

    @IBAction func getLastRetrievedClaimsNull() {
        let claims = createProvider(issuer: DOMAIN_URL, redirectURL: REDIRECT_URL)
            .getLastRetrievedClaims()

        accessTokenL.text = NO_ACCESS_TOKEN
        if let claims = claims {
            claimsL.text = claims.description
        } else {
            claimsL.text = NO_CLAIMS
        }
        errorL.text = NO_ERROR
    }

    @IBAction func logoutSuccess() {
        let provider = createProvider(issuer: DOMAIN_URL, redirectURL: REDIRECT_URL, postLogout: true)
        provider.startFlow(viewController: self) { _, _ in
            provider.logout(viewController: self) { error in
                if let error = error {
                    self.accessTokenL.text = self.NO_ACCESS_TOKEN
                    self.claimsL.text = self.NO_CLAIMS
                    self.errorL.text = error.localizedDescription
                } else {
                    self.accessTokenL.text = self.NO_ACCESS_TOKEN
                    self.claimsL.text = self.NO_CLAIMS
                    self.errorL.text = self.NO_ERROR
                }
            }
        } onError: { error in
            self.accessTokenL.text = self.NO_ACCESS_TOKEN
            self.claimsL.text = self.NO_CLAIMS
            self.errorL.text = error.localizedDescription
        }
    }

    @IBAction func logoutNotAuthenticatedState() {
        createProvider(issuer: DOMAIN_URL, redirectURL: REDIRECT_URL, postLogout: true)
            .logout(viewController: self) { error in
                if let error = error {
                    self.accessTokenL.text = self.NO_ACCESS_TOKEN
                    self.claimsL.text = self.NO_CLAIMS
                    self.errorL.text = error.localizedDescription
                } else {
                    self.accessTokenL.text = self.NO_ACCESS_TOKEN
                    self.claimsL.text = self.NO_CLAIMS
                    self.errorL.text = self.NO_ERROR
                }
            }
    }

    @IBAction func checkAuthenticatedWithAuthenticatedState() {
        let provider = createProvider(issuer: DOMAIN_URL, redirectURL: REDIRECT_URL)
        provider.startFlow(viewController: self) { _, _ in
            provider.checkAuthenticated { isAuthenticated in
                self.isAuthenticatedL.text = isAuthenticated.description
                self.errorL.text = self.NO_ERROR
            }
        } onError: { error in
            self.isAuthenticatedL.text = "No isAuthenticated"
            self.errorL.text = error.localizedDescription
        }
    }

    @IBAction func checkAuthenticatedUsingRefreshToken() {
        let provider = createProvider(issuer: EXPIRY_DOMAIN_URL, redirectURL: EXPIRY_REDIRECT_URL)
        provider.startFlow(viewController: self) { _, _ in
            // NOTE: wait until access token is expired
            Thread.sleep(forTimeInterval: 2)

            provider.checkAuthenticated { isAuthenticated in
                self.isAuthenticatedL.text = isAuthenticated.description
                self.errorL.text = self.NO_ERROR
            }
        } onError: { error in
            self.isAuthenticatedL.text = "No isAuthenticated"
            self.errorL.text = error.localizedDescription
        }
    }

    @IBAction func checkAuthenticatedWithoutAuthenticatedState() {
        createProvider(issuer: DOMAIN_URL, redirectURL: REDIRECT_URL)
            .checkAuthenticated { isAuthenticated in
                self.isAuthenticatedL.text = isAuthenticated.description
                self.errorL.text = self.NO_ERROR
            }
    }

    private func createProvider(
        issuer: URL,
        redirectURL: URL,
        postLogout: Bool = false,
        clearStorage: Bool = true,
        resetLabels: Bool = true
    ) -> AuthProvider {
        if clearStorage {
            let query = [
                kSecAttrAccount: "com.strivacity.sdk.AuthState",
                kSecClass: kSecClassGenericPassword,
            ] as [CFString: Any] as CFDictionary
            SecItemDelete(query)
        }

        if resetLabels {
            accessTokenL.text = ""
            claimsL.text = ""
            errorL.text = ""
            isAuthenticatedL.text = ""
        }

        let provider = AuthProvider.create(
            issuer: issuer,
            redirectUri: redirectURL,
            clientId: "clientid",
            storage: nil
        )

        if postLogout {
            let _ = provider.withPostLogoutUri(REDIRECT_URL)
        }

        appDelegate.authProvider = provider

        return provider
    }
}
