import AppAuth
import os

class AuthStateManager: NSObject, OIDAuthStateChangeDelegate {
    
    private let storage: Storage

    private var currentState: OIDAuthState? = nil
    
    public init(storage: Storage) {
        self.storage = storage
    }
    
    func getCurrentState() -> OIDAuthState? {
        log("get current state")
        if currentState == nil {
            currentState = storage.getState()
        }
        currentState?.stateChangeDelegate = self
        return currentState
    }
    
    func setCurrentState(state: OIDAuthState?) {
        log("set current state")
        storage.setState(authState: state)
        currentState = state
        currentState?.stateChangeDelegate = self
    }
    
    func resetCurrentState() {
        log("reset current state")
        storage.clear()
        currentState = nil
    }
    
    private func log(_ msg: StaticString) {
        os_log(msg, log: OSLog(subsystem: "com.strivacity.sdk", category: "sdk-debug"), type: .info)
    }

    func didChange(_ state: OIDAuthState) {
        log("state is changed, store it")
        setCurrentState(state: state)
    }
}
