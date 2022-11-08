//
//  StringExtension.swift
//  Strivacity
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation

/**
 * Extends the String class functionality to perform conversion from base64 to base64url and vice versa.
 */
extension String {
    
    /**
     * Converts base64url encoded string to base64 encoded.
     *
     * - Returns: base64 encoded string.
     */
    func base64UrlToBase64() -> String {
        var base64String = self.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        for _ in 0..<self.count % Constants.defaultPaddingCount {
            base64String += "="
        }
        
        return base64String
    }
    
    /**
     * Converts base64 encoded string to base64url encoded.
     *
     * - Returns: base64url encoded string.
     */
    func base64ToBase64Url() -> String {
        var base64UrlString = self.replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_")
        while base64UrlString.last == "=" {
            _ = base64UrlString.removeLast()
        }
        
        return base64UrlString
    }
}
