//
//  PublicKeyCreator.swift
//  Strivacity
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

import Foundation

/**
 * Manages public key creation
 */
class PublicKeyCreator: IPublicKeyCreator {
    
    /**
      Creates public key
     
      - Parameters:
        - modulus: String value obtained from the jwks url.
        - exponent: String value obtained from the jwks url.
     
      - Returns: Public key is returned on success or nil on failure.
     */
    func createPublicKey(modulus: String, exponent: String) -> SecKey? {
        let modulusArray: [UInt8] = Array(modulus.utf8)
        let exponentArray: [UInt8] = Array(exponent.utf8)
        
        var modulusEncoded: [UInt8] = []
        modulusEncoded.append(0x02)
        modulusEncoded.append(contentsOf: lengthField(of: modulusArray))
        modulusEncoded.append(contentsOf: modulusArray)
        
        var exponentEncoded: [UInt8] = []
        exponentEncoded.append(0x02)
        exponentEncoded.append(contentsOf: lengthField(of: exponentArray))
        exponentEncoded.append(contentsOf: exponentArray)
        
        var sequenceEncoded: [UInt8] = []
        sequenceEncoded.append(0x30)
        sequenceEncoded.append(contentsOf: lengthField(of: (modulusEncoded + exponentEncoded)))
        sequenceEncoded.append(contentsOf: (modulusEncoded + exponentEncoded))
        
        let keyData = Data(sequenceEncoded)
        let keySize = (modulusArray.count * Constants.bitsInByteCount)
        
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits as String: keySize
        ]
        
        let publicKey = SecKeyCreateWithData(keyData as CFData, attributes as CFDictionary, nil)
        print("publicKey: \(String(describing: publicKey))")
        
        return publicKey
    }
    
    private func lengthField(of valueField: [UInt8]) -> [UInt8] {
        var count = valueField.count

        if count < Constants.sixteenBytesInBitsCount {
            return [ UInt8(count) ]
        }

        // The number of bytes needed to encode count.
        let lengthBytesCount = Int((log2(Double(count)) / Double(Constants.bitsInByteCount)) + 1)

        // The first byte in the length field encoding the number of remaining bytes.
        let firstLengthFieldByte = UInt8(Constants.sixteenBytesInBitsCount + lengthBytesCount)

        var lengthField: [UInt8] = []
        for _ in 0..<lengthBytesCount {
            // Take the last 8 bits of count.
            let lengthByte = UInt8(count & 0xff)
            // Add them to the length field.
            lengthField.insert(lengthByte, at: 0)
            // Delete the last 8 bits of count.
            count = count >> Constants.bitsInByteCount
        }

        // Include the first byte.
        lengthField.insert(firstLengthFieldByte, at: 0)

        return lengthField
    }
}
