import XCTest

final class TestAppUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = true

        app = XCUIApplication()
        app.launch()

        addUIInterruptionMonitor(withDescription: "permission handler") { permission in
            let continueButton = permission.buttons["Continue"]
            if continueButton.exists {
                continueButton.tap()
                return true
            }
            return false
        }
    }

    func testStartFlowSuccess() throws {
        tapOnButton("StartFlowSuccess")
        expectNonEmptyAccessToken()
        expectNonEmptyClaims()
        expectEmptyError()
    }

    func testStartFlowWrongDomain() throws {
        tapOnButton("StartFlowWrongDomain", tapOnApp: false)
        expectEmptyAccessToken()
        expectEmptyClaims()
        expectNonEmptyError(
            msg: "Non-200 HTTP response (404) fetching discovery document 'http://example.com/.well-known/openid-configuration'."
        )
    }

    func testGetAccessTokenSuccess() throws {
        tapOnButton("GetAccessTokenSuccess")
        expectNonEmptyAccessToken()
        expectEmptyClaims()
        expectEmptyError()
    }

    func testGetAccessTokenUsingRefreshToken() throws {
        tapOnButton("GetAccessTokenUsingRefreshToken")
        expectNonEmptyAccessToken()
        expectEmptyClaims()
        expectEmptyError()
    }

    func testGetAccessTokenReturnsError() throws {
        tapOnButton("GetAccessTokenReturnsError", tapOnApp: false)
        expectEmptyAccessToken()
        expectEmptyClaims()
        expectNonEmptyError(msg: "You have to perform a login before use this")
    }

    func testGetLastRetrievedClaimsSuccess() throws {
        tapOnButton("GetLastRetrievedClaimsSuccess")
        expectEmptyAccessToken()
        expectNonEmptyClaims()
        expectEmptyError()
    }

    func testGetLastRetrievedClaimsNull() throws {
        tapOnButton("GetLastRetrievedClaimsNull", tapOnApp: false)
        expectEmptyAccessToken()
        expectEmptyClaims()
        expectEmptyError()
    }

    func testLogoutSuccess() throws {
        tapOnButton("LogoutSuccess")
        expectEmptyAccessToken()
        expectEmptyClaims()
        expectEmptyError()
    }

    func testLogoutNotAuthenticatedState() throws {
        tapOnButton("LogoutNotAuthenticatedState", tapOnApp: false)
        expectEmptyAccessToken()
        expectEmptyClaims()
        expectEmptyError()
    }

    func testCheckAuthenticatedWithAuthenticatedState() throws {
        tapOnButton("CheckAuthenticatedWithAuthenticatedState")
        expectEmptyError()
        expectIsAuthenticatedTrue()
    }

    func testCheckAuthenticatedUsingRefreshToken() throws {
        tapOnButton("CheckAuthenticatedUsingRefreshToken")
        expectEmptyError()
        expectIsAuthenticatedTrue()
    }

    func testCheckAuthenticatedWithoutAuthenticatedState() throws {
        tapOnButton("CheckAuthenticatedWithoutAuthenticatedState", tapOnApp: false)
        expectEmptyError()
        expectIsAuthenticatedFalse()
    }

    // MARK: - HELPER FUNCTIONS

    private func tapOnButton(_ buttonName: String, tapOnApp: Bool = true) {
        app.buttons[buttonName].tap()
        if tapOnApp {
            app.tap()
        }
    }

    private func expectNonEmptyAccessToken() {
        expectFor(text: "No access token", labelId: "AccessToken", not: true)
        expectFor(regex: #"[a-zA-Z0-9\-_\.]+"#, labelId: "AccessToken")
    }

    private func expectNonEmptyClaims() {
        expectFor(regex: ".+http://localhost:8080/default.+", labelId: "Claims")
    }

    private func expectNonEmptyError(msg: String) {
        expectFor(text: msg, labelId: "Error")
    }

    private func expectEmptyError() {
        expectFor(text: "No error", labelId: "Error")
    }

    private func expectEmptyAccessToken() {
        expectFor(text: "No access token", labelId: "AccessToken")
    }

    private func expectEmptyClaims() {
        expectFor(text: "No claims", labelId: "Claims")
    }

    private func expectIsAuthenticatedFalse() {
        expectFor(text: "false", labelId: "IsAuthenticated")
    }

    private func expectIsAuthenticatedTrue() {
        expectFor(text: "true", labelId: "IsAuthenticated")
    }

    private func expectFor(regex: String, labelId: String) {
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let label = app.staticTexts[labelId].label
        expectation(for: predicate, evaluatedWith: label)
        waitForExpectations(timeout: 5)
    }

    private func expectFor(text: String, labelId: String, not: Bool = false) {
        var predicate: NSPredicate
        if not {
            predicate = NSPredicate(format: "NOT SELF == %@", text)
        } else {
            predicate = NSPredicate(format: "SELF == %@", text)
        }
        let label = app.staticTexts[labelId].label
        expectation(for: predicate, evaluatedWith: label)
        waitForExpectations(timeout: 5)
    }
}
