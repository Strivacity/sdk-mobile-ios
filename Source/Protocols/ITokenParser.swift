//
//  IParser.swift
//  Strivacity
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation

/**
 * Protocol specifies method which should be implemented by id token parser.
 */
protocol ITokenParser {
    
    /**
     * Parses the id token string
     *
     * - Parameters:
     *   - stringToParse: The string obtained using AppAuth framework.
     *   - error: An error which can occur during the parsing
     *   (it is passed as inout parameter so, its value can be set inside the function).
     *
     * - Returns: Valid [IdToken] object is returned on success or nil on failure.
     */
    func parse(_ stringToParse: String, error: inout NSError?) -> IdToken? 
}
