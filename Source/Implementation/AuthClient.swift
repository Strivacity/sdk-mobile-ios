//
//  AuthClient.swift
//  Strivacity
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation
import AppAuth

/**
 * Specifies types of flows supported by the API.
 */
public enum FlowType {
    /// authorization code flow
    case AuthCode
    /// hybrid flow
    case Hybrid
    /// id token request
    case IdToken
    /// access token request
    case AccessToken
    /// logout flow
    case Logout
}

/**
 * Internal implementation of IAuthClient protocol
 */
public class AuthClient: IAuthClient, Equatable {
    /// object that stores information required for authentication.
    private var config: Config
    /// object that handles storing auth state
    private let keychainStorage: ISecureStorage?
    /// object that creates basic OAuth 2.0 endpoints URLs
    private let urlFactory: IUrlFactory = UrlFactory()
    /// object that manages the id token validation.
    private let validationManager: IValidationManager = ValidationManager()
    /// object that manages requests to the AppAuth framework.
    private let authServiceProvider: IAuthServiceProvider
    /// object that manages current authorization state
    private var authStateProvider: IAuthStateProvider
    /// represents an in-flight external user-agent session
    private var currentAuthorizationFlow: OIDExternalUserAgentSession?
    /// represents the information needed to construct a OIDAuthorizationService.
    private var configuration: OIDServiceConfiguration?
    
    /**
     * Initialises AuthClient with:
     *
     * - Parameters:
     *  - config: Contains information required for authentication.
     *  - authState: Can be specified as initial state for the client.
     *  - secureStorage: Represents the object used to store the authState object
     *  and access it between the app launches (can be nil, in this case the state is not stored).
     *  - authServiceProvider: manages requests to AppAuth framework.
     *  - authStateProvider: stores and manages OIDAuthState object.
     */
    init(config: Config, authState: OIDAuthState?, secureStorage: ISecureStorage?, authServiceProvider: IAuthServiceProvider = AuthServiceProvider(), authStateProvider: IAuthStateProvider = AuthStateProvider()) {
        self.config = config
        self.authStateProvider = authStateProvider
        self.authStateProvider.setAuthState(authState)
        self.keychainStorage = secureStorage
        self.authServiceProvider = authServiceProvider
        
        if let keychainStorage = self.keychainStorage {
            if let authState = authState {
                self.saveToSecureStorage(authState: authState)
            } else if let storedState = keychainStorage.getAuthInfo() as? OIDAuthState {
                self.authStateProvider.setAuthState(storedState)
            }
        }
    }
    
    /**
      Implementation of the Equatable protocol, to be able to compare [AuthClient] objects.
     
      - Parameters:
        - lhs: first object
        - rhs: second object
     
      - Returns: Boolean value, true if the objects are equal, false otherwise.
     */
    public static func == (lhs: AuthClient, rhs: AuthClient) -> Bool {
        let lhsSecureStorage = lhs.keychainStorage == nil
        let rhsSecureStorage = rhs.keychainStorage == nil
        return lhs.config == rhs.config && lhsSecureStorage == rhsSecureStorage && lhs.authStateProvider.getAuthState() as? OIDAuthState == rhs.authStateProvider.getAuthState() as? OIDAuthState
    }
    
    /**
      Sends an authorization request to perform authorization flow
      [See Strivacity APIs, Authentication APIs, Begin an OIDC Authorization Code Flow](https://api.strivacity.com/)
      [See OpenID Connect Core 1.0, Section 3.1](https://openid.net/specs/openid-connect-core-1_0.html#CodeFlowAuth)
     
      - Parameters:
        - viewController: The UIViewController to present auth flow request.
        - completion: The callback to invoke upon request completion.
     */
    public func authorizeAuthCodeFlow(viewController: UIViewController, completion: @escaping (Result<AnyObject, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.performAuthorization(.AuthCode, viewController: viewController, completion: completion)
        }
    }
    
    /**
     * Sends request to obtain an id token from auth code
     * [See Strivacity Authentication APIs, Obtain an ID Token from an Authorization Code](https://api.strivacity.com/)
     * [See OpenID Connect Core 1.0, Section 2](https://openid.net/specs/openid-connect-core-1_0.html#IDToken)
     * Note: The authorization code must already be obtained from [authorizeAuthCodeFlow] or [authorizeHybridFlow]
     *
     * - Parameter completion: The callback to invoke upon request completion.
     */
    public func requestIdToken(completion: @escaping (Result<AnyObject, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let tokenExchangeRequest = self.authStateProvider.getTokenExchangeRequest() else {
                print("Failed to obtain token exchange request from last authorization response.")
                completion(.failure(APIError.failedToObtainTokenExchangeRequestFromLastAuthorizationResponse))
                return
            }
            
            let tokenRequest = OIDTokenRequest(
                configuration: tokenExchangeRequest.configuration,
                grantType: OIDGrantTypeAuthorizationCode,
                authorizationCode: tokenExchangeRequest.authorizationCode,
                redirectURL: tokenExchangeRequest.redirectURL,
                clientID: self.config.clientId,
                clientSecret: self.config.clientSecret,
                scope: nil,
                refreshToken: nil,
                codeVerifier: tokenExchangeRequest.codeVerifier,
                additionalParameters: nil)
            
            let (tokenResponse, error) = self.authServiceProvider.performTokenRequest(tokenRequest)
            self.authStateProvider.update(tokenResponse, error: error)
            self.handleTokenObtainResult(tokenResponse: tokenResponse, error: error, completion: completion)
        }
    }
    
    /**
     * Sends request to obtain an access token via client credentials
     * [See Strivacity Authentication APIs, Obtain an Access Token via Client Credentials](https://api.strivacity.com/)
     *
     * - Parameter completion: The callback to invoke upon request completion.
     */
    public func requestAccessToken(viewController: UIViewController, completion: @escaping (Result<AnyObject, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.performAuthorization(.AccessToken, viewController: viewController, completion: completion)
        }
    }
    
    /**
      Sends an authorization request to perform hybrid flow
      [See Strivacity APIs, Authentication APIs, Begin an OIDC Hybrid Flow](https://api.strivacity.com/)
      [See OpenID Connect Core 1.0, Section 3.3](https://openid.net/specs/openid-connect-core-1_0.html#HybridFlowAuth)
     
      - Parameters:
        - viewController: The UIViewController to present hybrid flow request.
        - completion: The callback to invoke upon request completion.
     */
    public func authorizeHybridFlow(viewController: UIViewController, completion: @escaping (Result<AnyObject, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.performAuthorization(.Hybrid, viewController: viewController, completion: completion)
        }
    }
    
    /**
      Sends request to perform logout
      [See Strivacity Authentication APIs, Begin an OIDC Initiated Logout](https://api.strivacity.com/)
      [See OpenID Connect RP-Initiated Logout 1.0 - draft 01](https://openid.net/specs/openid-connect-rpinitiated-1_0.html)
     
      - Parameters:
        - viewController: The UIViewController to present logout request.
        - completion: The callback to invoke upon request completion.
     */
    public func logout(viewController: UIViewController, completion: @escaping (Result<Bool, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let (logoutUrl, authEndpoint, tokenEndpoint, idToken) = self.getLogoutComponents() else {
                completion(.failure(APIError.failedToObtainLogoutComponents))
                return
            }
            
            guard let redirectUrl = URL(string: self.config.redirectUri), (redirectUrl.host != nil) else {
                completion(.failure(APIError.failedToObtainRedirectUri))
                return
            }
            
            guard let agent = OIDExternalUserAgentIOS(presenting: viewController) else {
                print("Failed to create external user agent.")
                completion(.failure(APIError.failedToCreateExternalUserAgent))
                return
            }
            
            let configuration = OIDServiceConfiguration(authorizationEndpoint: authEndpoint, tokenEndpoint: tokenEndpoint, issuer: nil, registrationEndpoint: nil, endSessionEndpoint: logoutUrl)
            let endSessionRequest = OIDEndSessionRequest(configuration: configuration, idTokenHint: idToken, postLogoutRedirectURL: redirectUrl, additionalParameters: nil)
            
            let (_, session, error) = self.authServiceProvider.presentEndSessionRequest(endSessionRequest, externalUserAgent: agent)
            self.currentAuthorizationFlow = session
            if error != nil {
                completion(.success(true))
            }
            
            self.removeFromSecureStorage(completion: completion)
        }
    }
    
    /**
     * Handles the redirect of the authorization response url.
     *
     * - Parameter url: authorization response url
     *
     * - Returns: result of redirection, true on success, false on failure.
     */
    public func proceedExternalUserAgentFlow(with url: URL) -> Bool {
        if let currentAuthorizationFlow = self.currentAuthorizationFlow, currentAuthorizationFlow.resumeExternalUserAgentFlow(with: url) {
            self.currentAuthorizationFlow = nil
            return true
        }
        
        return false
    }
    
    /**
     * Gives actual [authentication state](OIDAuthState)
     *
     * - Returns: authentication state
     */
    public func getAuthState() -> AnyObject? {
        return self.authStateProvider.getAuthState()
    }
    
    // MARK: - private methods
    /**
      Performs common steps for different authorization types.
     
      - Parameters:
        - type: Specifies authorization type which is used on the next step.
        - viewController: The UIViewController to present auth flow request.
        - completion: The callback to invoke upon request completion.
     */
    private func performAuthorization(_ type: FlowType, viewController: UIViewController, completion: @escaping (Result<AnyObject, Error>) -> Void) {
        guard let issuer = URL(string: Constants.httpsPrefix + self.config.domain), (issuer.host != nil) else {
            print("Failed to get domain URL from config.")
            completion(.failure(APIError.failedToCreateDomainUrlFromConfig))
            return
        }
        
        print("Fetching configuration for issuer: \(issuer).")
        let (serviceConfig, error) = self.authServiceProvider.discoverServiceConfig(for: issuer)
        guard let serviceConfig = serviceConfig, error == nil else {
            completion(.failure(error ?? APIError.failedToDiscoverConfiguration))
            return
        }
        
        self.configuration = serviceConfig
        print("Got configuration: \(serviceConfig)")
        
        guard let redirectUri = URL(string: self.config.redirectUri), (redirectUri.host != nil) else {
            print("Error redirect URI is Empty")
            completion(.failure(APIError.failedToObtainRedirectUri))
            return
        }
        
        self.authorize(type: type, configuration: serviceConfig, redirectUri: redirectUri, viewController: viewController, completion: completion)
    }
    
    /**
      Calls the appropriate method based on the flow type.
     
      - Parameters:
        - type: Specifies authorization type which is used to determine
        the specific method for the each flow.
        - configuration: Service configuration obtained for specified domain.
        - redirectUri: URL created from the [Config] member.
        - viewController: The UIViewController to present auth flow request.
        - completion: The callback to invoke upon request completion.
     */
    private func authorize(type: FlowType, configuration: OIDServiceConfiguration, redirectUri: URL, viewController: UIViewController, completion: @escaping (Result<AnyObject, Error>) -> Void) {
        switch type {
        case .AuthCode:
            doAuthorizationForAuthCodeFlow(configuration: configuration, redirectUri: redirectUri, viewController: viewController, completion: completion)
            break
        case .Hybrid:
            doAuthorizationForHybridFlow(configuration: configuration, redirectUri: redirectUri, viewController: viewController, completion: completion)
            break
        case .AccessToken:
            doAccessTokenRequest(configuration: configuration, redirectUri: redirectUri, completion: completion)
            break
        case .IdToken, .Logout:
            break
        }
    }
    
    private func doAuthorizationForAuthCodeFlow(configuration: OIDServiceConfiguration, redirectUri: URL, viewController: UIViewController, completion: @escaping (Result<AnyObject, Error>) -> Void) {
        self.doAuthWithoutCodeExchange(configuration: configuration, redirectUri: redirectUri, clientID: self.config.clientId, clientSecret: nil, scopes: [OIDScopeOpenID, OIDScopeProfile], viewController: viewController, completion: { result in
            self.handleResult(result, with: completion)
        })
    }
    
    /**
     * Replaces the '#' characters to '?' in the string and creates URL from it.
     * ASWebAuthenticationSession gives us the URL with '#' character inside
     * and the OIDURLQueryComponent object can't be created from this url.
     * To be able to create OIDURLQueryComponent object we need to replace this character.
     *
     * - Parameter url: URL to obtain string for modification.
     *
     * - Returns: Modified URL
     */
    private func modifyUrl(_ url: URL) -> URL? {
        var str = url.absoluteString
        str = str.replacingOccurrences(of: "#", with: "?", options: .literal, range: nil)
        
        return URL(string: str)
    }
    
    /**
     * Performs validation of the authorization response obtained via the AppAuth framework.
     *
     * - Parameter response: Response to validate.
     *
     * - Returns: Response object and nil as error on success or nil as responce and error on failure.
     */
    private func validateResponse(_ response: OIDAuthorizationResponse?) -> (OIDAuthorizationResponse?, NSError?) {
        guard let unwrappedResponse = response else {
            print("Authorization response is not valid.")
            return (nil, APIError.failedToUnwrapAuthResponse as NSError)
        }
        
        guard let jwksUrl = self.configuration?.discoveryDocument?.jwksURL else {
            print("Failed to get jwks url.")
            return (nil, APIError.failedToUnwrapJwksUrl as NSError)
        }
        
        var error: NSError?
        
        if validationManager.validate(idTokenString: unwrappedResponse.idToken, authorizationCode: unwrappedResponse.authorizationCode, clientId: unwrappedResponse.request.clientID, nonce: unwrappedResponse.request.nonce ?? "", jwksUrl: jwksUrl, config: self.config, error: &error) {
            return (unwrappedResponse, nil)
        }
        
        return (nil, error)
    }
    
    /**
      Creates authorization response.
     
      - Parameters:
        - url: URL to obtain parameters for response creation.
        - request: Request object which is used for response creation.
     
      - Returns: Response object and nil as error on success or nil as responce and error on failure.
     */
    private func createAuthResponse(url: URL, request: OIDAuthorizationRequest) -> (OIDAuthorizationResponse?, NSError?) {
        var response: OIDAuthorizationResponse?
        var internalError: NSError?
        
        guard let query = OIDURLQueryComponent(url: url) else {
            print("Failed to create query from url.")
            internalError = APIError.unexpectedError as NSError
            return (response, internalError)
        }
        
        if query.dictionaryValue[OIDOAuthErrorFieldError] != nil {
            internalError = OIDErrorUtilities.oAuthError(withDomain: OIDOAuthAuthorizationErrorDomain, oAuthResponse: query.dictionaryValue, underlyingError: nil) as NSError
            return (nil, internalError)
        }
        
        response = OIDAuthorizationResponse(request: request, parameters: query.dictionaryValue)
        if request.state != response?.state {
            var userInfo = query.dictionaryValue
            userInfo[NSLocalizedDescriptionKey] = "State mismatch" as NSCopying & NSObjectProtocol
            response = nil
            internalError = NSError.init(domain: OIDOAuthAuthorizationErrorDomain, code: OIDErrorCodeOAuthAuthorization.clientError.rawValue, userInfo: userInfo)
            return (nil, internalError)
        }
            
        return self.validateResponse(response)
    }
    
    /**
      Presents hybrid flow authorization request.
     
      - Parameters:
        - request: Request to be presented.
        - userAgent: Agent which takes part in request presentation.
        - authorizationSession: Session that should be stored in case of success response.
        - viewController: The UIViewController to present hybrid flow request.
        - completion: The callback to invoke upon request completion.
     */
    private func presentRequest(_ request: OIDAuthorizationRequest, userAgent: OIDExternalUserAgentIOS, authorizationSession: OIDAuthorizationSession, viewController: UIViewController, completion: @escaping (Result<AnyObject, Error>) -> Void) {
        guard let requestUrl = request.externalUserAgentRequestURL() else {
            print("Failed to obtain url or redirect scheme from authorization request.")
            completion(.failure(APIError.failedToObtainRequestUrl))
            return
        }
        
        if UIAccessibility.isGuidedAccessEnabled {
            print("Failed to run authentication session, because app is under guided access mode.")
            completion(.failure(APIError.failedToRunAuthSessionAppIsUnderGuidedAccessMode))
            return
        }
        
        let (url, error) = authServiceProvider.presentHybridFlowRequest(requestUrl, scheme: request.redirectScheme(), userAgent: userAgent)
        guard let unwrappedUrl = url else {
            let err = OIDErrorUtilities.error(with: OIDErrorCode.userCanceledAuthorizationFlow, underlyingError: error, description: "")
            print("User canceled authorization flow, error: \(err)")
            completion(.failure(err))
            return
        }
        
        guard let modifiedUrl = self.modifyUrl(unwrappedUrl) else {
            print("Failed to modify url.")
            completion(.failure(APIError.failedToModifyUrl))
            return
        }
        
        print("modified url: \(modifiedUrl)")
        let (response, internalError) = self.createAuthResponse(url: modifiedUrl, request: request)
        
        userAgent.dismiss(animated: true, completion: {
            if let response = response {
                self.authStateProvider.setAuthState(response)
                self.currentAuthorizationFlow = authorizationSession
                self.requestIdToken(completion: completion)
            } else {
                completion(.failure(internalError ?? APIError.unexpectedError))
                print("Authorization error: \(internalError?.localizedDescription ?? "DEFAULT_ERROR")")
            }
        })
    }
    
    /**
      Performs authorization for the hybrid flow.
     
      - Parameters:
        - configuration: Service configuration obtained for specified domain.
        - redirectUri: URL created from the [Config] member.
        - viewController: The UIViewController to present auth flow request.
        - completion: The callback to invoke upon request completion.
     */
    private func doAuthorizationForHybridFlow(configuration: OIDServiceConfiguration, redirectUri: URL, viewController: UIViewController, completion: @escaping (Result<AnyObject, Error>) -> Void) {
        let request = OIDAuthorizationRequest(configuration: configuration,
                                              clientId: self.config.clientId,
                                              clientSecret: nil,
                                              scopes: [OIDScopeOpenID, OIDScopeProfile],
                                              redirectURL: redirectUri,
                                              responseType: OIDResponseTypeCode + " " + OIDResponseTypeIDToken,
                                              additionalParameters: nil)
        
        guard let externalUserAgent = OIDExternalUserAgentIOS(presenting: viewController) else {
            completion(.failure(APIError.failedToCreateExternalUserAgent))
            return
        }
        
        guard let authorizationSession = OIDAuthorizationSession(request: request) else {
            completion(.failure(APIError.failedToCreateAuthorizationSession))
            return
        }
        
        presentRequest(request, userAgent: externalUserAgent, authorizationSession: authorizationSession, viewController: viewController, completion: completion)
    }
    
    /**
     * Performs access token request.
     *
     * - Parameters:
     *   - configuration: Service configuration obtained for specified domain.
     *   - redirectUri: URL created from the [Config] member.
     *   - viewController: The UIViewController to present auth flow request.
     *   - completion: The callback to invoke upon request completion.
     */
    private func doAccessTokenRequest(configuration: OIDServiceConfiguration, redirectUri: URL, completion: @escaping (Result<AnyObject, Error>) -> Void) {
        let tokenRequest = OIDTokenRequest(
            configuration: configuration,
            grantType: OIDGrantTypeClientCredentials,
            authorizationCode: nil,
            redirectURL: redirectUri,
            clientID: self.config.clientId,
            clientSecret: self.config.clientSecret,
            scope: nil,
            refreshToken: nil,
            codeVerifier: nil,
            additionalParameters: [Constants.audienceKey : self.config.domain])
        
        let (tokenResponse, error) = self.authServiceProvider.performTokenRequest(tokenRequest)
        if self.authStateProvider.getAuthState() == nil {
            let authRequest = OIDAuthorizationRequest.init(configuration: configuration, clientId: self.config.clientId, clientSecret: self.config.clientSecret, scopes: nil, redirectURL: redirectUri, responseType: OIDResponseTypeCode, additionalParameters: nil)
            let authResponse = OIDAuthorizationResponse.init(request: authRequest, parameters: [:])
            self.authStateProvider.setAuthState(authResponse, tokenResponse: tokenResponse)
        } else {
            self.authStateProvider.update(tokenResponse, error: error)
        }
        
        self.handleTokenObtainResult(tokenResponse: tokenResponse, error: error, completion: completion)
    }
    
    /**
     * Performs authorization code flow.
     *
     * - Parameters:
     *   - configuration: Service configuration obtained for specified domain.
     *   - redirectUri: URL created from the [Config] member.
     *   - viewController: The UIViewController to present auth flow request.
     *   - completion: The callback to invoke upon request completion.
     */
    private func doAuthWithoutCodeExchange(configuration: OIDServiceConfiguration, redirectUri: URL, clientID: String, clientSecret: String?, scopes: [String], viewController: UIViewController, completion: @escaping (Result<AnyObject, Error>) -> Void) {
        let request = OIDAuthorizationRequest(configuration: configuration,
                                              clientId: clientID,
                                              clientSecret: clientSecret,
                                              scopes: scopes,
                                              redirectURL: redirectUri,
                                              responseType: OIDResponseTypeCode,
                                              additionalParameters: nil)
        
        print("Initiating authorization request with scope: \(request.scope ?? "DEFAULT_SCOPE")")
        let (authFlow, response, error) = self.authServiceProvider.presentAuthRequest(request, viewController: viewController)
        self.currentAuthorizationFlow = authFlow
        if let response = response {
            let authState = OIDAuthState(authorizationResponse: response)
            completion(.success(authState))
            print("Authorization response with code: \(response.authorizationCode ?? "DEFAULT_CODE")")
        } else {
            completion(.failure(error ?? APIError.unexpectedError))
        }
    }
    
    /**
     * Performs saving auth state to the secure storage.
     * If the secure storage usage set to false during the [AuthClient] object creation,
     * then authState object won't be stored because the keychainStorage property of the [AuthClient] is nil.
     *
     * - Parameter authState: Auth state to be stored in secure storage.
     */
    private func saveToSecureStorage(authState: AnyObject) {
        self.authStateProvider.setAuthState(authState as? OIDAuthState)
        self.keychainStorage?.setAuthInfo(authInfo: authState, completion: { result in
            switch result {
            case .success(_):
                break
            case .failure(let error):
                print(error)
                break
            }
        })
    }
    
    /**
     * Performs removing auth state from the secure storage.
     *
     * - Parameter completion: The callback to invoke upon the removal completion.
     */
    private func removeFromSecureStorage(completion: @escaping (Result<Bool, Error>) -> Void) {
        self.authStateProvider.setAuthState(nil)
        self.keychainStorage?.removeAuthInfo(completion: { result in
            switch result {
            case .success(let isSuccess):
                if isSuccess {
                    completion(.success(true))
                }
                break
            case .failure(let error):
                print(error)
                break
            }
        })
    }
    
    /**
     * Returns values which are used to perform logout.
     *
     * - Returns: logout url, authorization endpoint url, token endpoint url, id token.
     */
    private func getLogoutComponents() -> (logoutUrl: URL, authEndpoint: URL, tokenEndpoint: URL, idToken: String)? {
        guard let logoutUrl = self.urlFactory.getLogoutUrl(for: self.config.domain, shouldAddHttpsPrefix: true) else {
            print("Error creating URL for logout")
            return nil
        }
        
        guard let authEndPoint = self.urlFactory.getAuthServerHost(for: self.config.domain) else {
            print("Error creating URL for auth")
            return nil
        }
        
        guard let tokenEndPoint = self.urlFactory.getTokenRequestUrl(for: self.config.domain) else {
            print("Error creating URL for tokenEndpoint")
            return nil
        }
        
        guard let idToken = self.authStateProvider.getIdToken() else {
            print("Error creating idToken")
            return nil
        }
        
        return (logoutUrl, authEndPoint, tokenEndPoint, idToken)
    }
    
    /**
     * Handles authorization result.
     *
     * - Parameters:
     *   - result: Result to be handled.
     *   - completion: The callback to invoke after the result handling.
     */
    private func handleResult(_ result: Result<AnyObject, Error>, with completion: @escaping (Result<AnyObject, Error>) -> Void) {
        switch result {
        case .success(let authState):
            self.saveToSecureStorage(authState: authState)
            completion(.success(authState))
            break
        case .failure(let error):
            completion(.failure(error))
            break
        }
    }
    
    /**
     * Handles token obtaining result.
     *
     * - Parameters:
     *   - tokenResponse: Response to be handled.
     *   - error: Error which has been occurred during token request.
     *   - completion: The callback to invoke after the response handling.
     */
    private func handleTokenObtainResult(tokenResponse: OIDTokenResponse?, error: Error?, completion: @escaping (Result<AnyObject, Error>) -> Void) {
        if tokenResponse != nil, let state = self.authStateProvider.getAuthState() {
            self.saveToSecureStorage(authState: state)
            completion(.success(state))
        } else if let error = error {
            completion(.failure(error))
        }
    }
}
