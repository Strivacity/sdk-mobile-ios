//
//  Config.swift
//  Strivacity
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation

/**
 * The struct contains the information required for authentication.
 */
struct Config: Decodable, Equatable {
    
    /**
     * The client identifier.
     *
     * @see "The OAuth 2.0 Authorization Framework (RFC 6749), Section 4
     * <https://tools.ietf.org/html/rfc6749#section-4>"
     * @see "The OAuth 2.0 Authorization Framework (RFC 6749), Section 4.1.1
     * <https://tools.ietf.org/html/rfc6749#section-4.1.1>"
     */
    var clientId: String
    
    /**
     * The client secret.
     *
     * @see "OpenID Connect Dynamic Client Registration 1.0, Section 3.2
     * <https://openid.net/specs/openid-connect-discovery-1_0.html#rfc.section.3.2>"
     */
    var clientSecret: String
    
    /**
     * The domain of authentication server
     */
    var domain: String
    
    /**
     * The redirect URI's.
     *
     * @see "<https://tools.ietf.org/html/rfc6749#section-3.1.2> The OAuth 2.0
     * Authorization Framework" (RFC 6749), Section 3.1.2
     */
    var redirectUri: String
    
    enum CodingKeys: String, CodingKey {
        case clientId
        case clientSecret
        case domain
        case redirectUri
    }
}
