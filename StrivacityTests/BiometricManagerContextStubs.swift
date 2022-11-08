//
//  BiometricManagerContextStubs.swift
//  StrivacityTests
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation
import LocalAuthentication

class StubLAContextBiometricEnabledAndSucceded: LAContext {
    override func evaluatePolicy(_ policy: LAPolicy, localizedReason: String) async throws -> Bool { return true }
    override func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool { return true }
}

class StubLAContextBiometricDisabled: LAContext {
    override func evaluatePolicy(_ policy: LAPolicy, localizedReason: String) async throws -> Bool { return false }
    override func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool { return false }
}

class StubLAContextBiometricEnabledAndFailed: LAContext {
    override func evaluatePolicy(_ policy: LAPolicy, localizedReason: String) async throws -> Bool { return false }
    override func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool { return true }
}
