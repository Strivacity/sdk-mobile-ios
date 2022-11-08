//
//  ViewController.swift
//  Strivacity-usage-example
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import UIKit
import Strivacity
import AppAuth

protocol IAuthClientSetter {
    func setAuthClient(_ authClient: IAuthClient)
}

class ViewController: UIViewController, IAuthClientSetter {
    @IBOutlet weak var authButton: UIButton!
    @IBOutlet weak var hybridAuthButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var requestAccessTokenButton: UIButton!
    @IBOutlet weak var requestIdTokenButton: UIButton!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var authCodeLabel: UILabel!
    @IBOutlet weak var idTokenLabel: UILabel!
    @IBOutlet weak var accessTokenLabel: UILabel!
    @IBOutlet weak var authCodeTextView: UITextView!
    @IBOutlet weak var idTokenTextView: UITextView!
    @IBOutlet weak var accessTokenTextView: UITextView!
    
    private var authClient: IAuthClient?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.customizeStackViewSpacing(UIConstants.defaultSpacing, after: [UIConstants.authCodeTextViewIndex, UIConstants.idTokenTextViewIndex])
        self.setupTextViewsLookLike([self.authCodeTextView, self.idTokenTextView, self.accessTokenTextView],
                                    borderWidth: UIConstants.defaultTextViewBorderWidth,
                                    borderColor: UIColor.init(named: UIConstants.borderColorName)?.cgColor,
                                    backgroundColor: UIColor.init(named: UIConstants.textViewBackgroundColorName)?.cgColor)
        self.updateUI(authState: self.authClient?.getAuthState())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
       get {
          return .portrait
       }
    }
    
    func setAuthClient(_ authClient: IAuthClient) {
        self.authClient = authClient
        updateUI(authState: self.authClient?.getAuthState())
    }
    
    // MARK: - private methods
    private func customizeStackViewSpacing(_ newSpacing: CGFloat, after subviewsIndices: [Int]) {
        for index in subviewsIndices {
            self.stackView.setCustomSpacing(newSpacing, after: self.stackView.subviews[index])
        }
    }
    
    private func setupTextViewsLookLike(_ textViews: [UITextView], borderWidth: CGFloat, borderColor: CGColor?, backgroundColor: CGColor?) {
        for textView in textViews {
            textView.layer.borderWidth = borderWidth
            textView.layer.borderColor = borderColor
            textView.layer.backgroundColor = backgroundColor
        }
    }
    
    private func updateUI(authState: AnyObject?) {
        if authState != nil {
            self.setButtonsState(true, buttons: [requestIdTokenButton, requestAccessTokenButton, logoutButton])
        } else {
            self.setButtonsState(true, buttons: [authButton, requestAccessTokenButton])
            self.setButtonsState(false, buttons: [requestIdTokenButton, logoutButton])
        }
        
        self.setButtonsState(true, buttons: [hybridAuthButton])
        self.updateTextFields(authState)
    }
    
    private func updateTextFields(_ authState: AnyObject?) {
        self.authCodeTextView.text = authState?.lastAuthorizationResponse.authorizationCode ?? ""
        self.idTokenTextView.text = authState?.lastTokenResponse?.idToken ?? ""
        self.accessTokenTextView.text = authState?.lastTokenResponse?.accessToken ?? ""
    }
    
    private func setButtonsState(_ isEnabled: Bool, buttons: [UIButton]) {
        for button in buttons {
            button.isUserInteractionEnabled = isEnabled
            button.setTitleColor(isEnabled ? .white : .lightGray, for: .normal)
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Auth Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in }))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func handleResult(result: Result<AnyObject, Error>, shouldDisplayAlertWithAccessToken: Bool, shouldDisplayAlertWithAuthCode: Bool) {
        DispatchQueue.main.async {
            switch result {
            case .success(let authState):
                self.updateUI(authState: authState)
                
                if shouldDisplayAlertWithAuthCode, let authorizationCode = authState.lastAuthorizationResponse.authorizationCode {
                    self.showAlert(message: authorizationCode)
                } else if shouldDisplayAlertWithAccessToken, let accessToken = authState.lastTokenResponse?.accessToken {
                    self.showAlert(message: accessToken)
                }
                break
            case .failure(let error):
                self.showAlert(message: error.localizedDescription)
                print(error.localizedDescription)
                break
            }
        }
    }
    
    private func logoutCompletion(_ result: Result<Bool, Error>) {
        DispatchQueue.main.async {
            switch result {
            case .success(let isLogout):
                if isLogout {
                    self.updateUI(authState: nil)
                }
                break
            case .failure(let error):
                self.showAlert(message: error.localizedDescription)
                print(error.localizedDescription)
                break
            }
        }
    }
    
    private func performAction(for flowType: FlowType) {
        guard let authClient = authClient else {
            self.showAlert(message: "AuthClient was not initialized")
            return
        }
        
        switch flowType {
        case .AuthCode:
            authClient.authorizeAuthCodeFlow(viewController: self, completion: { result in
                self.handleResult(result: result, shouldDisplayAlertWithAccessToken: false, shouldDisplayAlertWithAuthCode: true)
            })
            break
        case .Hybrid:
            authClient.authorizeHybridFlow(viewController: self, completion: { result in
                self.handleResult(result: result, shouldDisplayAlertWithAccessToken: false, shouldDisplayAlertWithAuthCode: false)
            })
            break
        case .IdToken:
            authClient.requestIdToken(completion: { result in
                self.handleResult(result: result, shouldDisplayAlertWithAccessToken: false, shouldDisplayAlertWithAuthCode: false)
            })
            break
        case .AccessToken:
            authClient.requestAccessToken(viewController: self, completion: { result in
                self.handleResult(result: result, shouldDisplayAlertWithAccessToken: true, shouldDisplayAlertWithAuthCode: false)
            })
            break
        case .Logout:
            authClient.logout(viewController: self, completion: logoutCompletion(_:))
            break
        }
    }
    
    // MARK: - buttons click handlers
    @IBAction func authButtonClicked(_ sender: UIButton) {
        performAction(for: .AuthCode)
    }
    
    @IBAction func hybridAuthButtonClicked(_ sender: UIButton) {
        performAction(for: .Hybrid)
    }
    
    @IBAction func requestAccessTokenButtonClicked(_ sender: UIButton) {
        performAction(for: .AccessToken)
    }
    
    @IBAction func requestIdTokenButtonClicked(_ sender: UIButton) {
        performAction(for: .IdToken)
    }
    
    @IBAction func logoutButtonClicked(_ sender: UIButton) {
        performAction(for: .Logout)
    }
}
