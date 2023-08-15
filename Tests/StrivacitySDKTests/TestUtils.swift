import AppAuth

@testable import StrivacitySDK

class TestUtils {
    static func createAuthState(clientId: String) -> OIDAuthState {
        let config = OIDServiceConfiguration(
            authorizationEndpoint: URL(string: "http://example.com/auth")!,
            tokenEndpoint: URL(string: "http://example.com/token")!
        )
        let authRequest = OIDAuthorizationRequest(
            configuration: config,
            clientId: clientId,
            scopes: nil,
            redirectURL: URL(string: "http://example.com/callback")!,
            responseType: OIDResponseTypeCode,
            additionalParameters: nil
        )
        let authResponse = OIDAuthorizationResponse(request: authRequest, parameters: [:])
        return OIDAuthState(authorizationResponse: authResponse)
    }
    
    static func getValueFromCFDictionary(_ dict: CFDictionary, key: CFString) -> NSObject? {
        if let ptr = CFDictionaryGetValue(dict, Unmanaged.passUnretained(key).toOpaque()) {
            let value = Unmanaged<NSObject>.fromOpaque(ptr).takeUnretainedValue()
            return value
        }
        return nil
    }
}

class MockKeychainHelper: KeychainHelper {
    
    var setCallback: ((_ query: CFDictionary) -> OSStatus)!
    var updateCallback: ((_ query: CFDictionary, _ update: CFDictionary) -> Void)!
    var deleteCallback: ((_ query: CFDictionary) -> Void)!
    var getCallback: ((_ query: CFDictionary) -> AnyObject?)!
    
    override func set(_ query: CFDictionary) -> OSStatus {
        setCallback(query)
    }
    
    override func update(_ query: CFDictionary, update: CFDictionary) {
        updateCallback(query, update)
    }
    
    override func delete(_ query: CFDictionary) {
        deleteCallback(query)
    }
    
    override func get(_ query: CFDictionary) -> AnyObject? {
        getCallback(query)
    }
}
