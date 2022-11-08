//
//  Constants.swift
//  Strivacity
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation

/**
 * Class contains constants used in API.
 */
struct Constants {
    static let authPart = "/oauth2/auth"
    static let logoutPart = "/oauth2/sessions/logout"
    static let endpointTokenPart = "/oauth2/token"
    static let httpsPrefix = "https://"
    static let audienceKey = "audience"
    static let keyIdKey = "kid"
    static let algorithmKey = "alg"
    static let sidKey = "sid"
    static let authTimeKey = "auth_time"
    static let expTimeKey = "exp"
    static let ratTimeKey = "rat"
    static let iatTimeKey = "iat"
    static let clientIdKey = "client_id"
    static let userIdKey = "user_id"
    static let subjectKey = "sub"
    static let cHashKey = "c_hash"
    static let audKey = "aud"
    static let issuerKey = "iss"
    static let jwtIdKey = "jti"
    static let nonceKey = "nonce"
    static let exponentKey = "e"
    static let keyTypeKey = "kty"
    static let modulusKey = "n"
    static let usageKey = "use"
    static let jwksUrlObjectKey = "keys"
    static let defaultPaddingCount = 4
    static let bitsInByteCount = 8
    static let sixteenBytesInBitsCount = 128
    static let twoBytesInBitsCount = 16
}
