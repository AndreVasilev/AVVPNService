//
//  AVKeychainService.swift
//  AVVPNService
//
//  Created by Andrey Vasilev on 17.04.2020.
//  Copyright © 2020 Andrey Vasilev. All rights reserved.
//

import UIKit
import Security

class AVVPNKeychainService: NSObject {

    internal static let sharedKey = "SHARED"
    internal static let passwordKey = "VPN_PASSWORD"
    internal static let remoteIdKey = "VPN_REMOTE_ID"
    internal static let localIdKey = "VPN_LOCAL_ID"
    private let serviceValue = "VPN"

    // MARK: Arguments for the keychain queries

    private var kSecAttrAccessGroupSwift = NSString(format: kSecClass)

    private let kSecClassValue = kSecClass as CFString
    private let kSecAttrAccountValue = kSecAttrAccount as CFString
    private let kSecValueDataValue = kSecValueData as CFString
    private let kSecClassGenericPasswordValue = kSecClassGenericPassword as CFString
    private let kSecAttrServiceValue = kSecAttrService as CFString
    private let kSecMatchLimitValue = kSecMatchLimit as CFString
    private let kSecReturnDataValue = kSecReturnData as CFString
    private let kSecMatchLimitOneValue = kSecMatchLimitOne as CFString
    private let kSecAttrGenericValue = kSecAttrGeneric as CFString
    private let kSecAttrAccessibleValue = kSecAttrAccessible as CFString

    // MARK: Save

    func save(key: String, value: String) {
        let keyData: Data = key.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue), allowLossyConversion: false)!
        let valueData: Data = value.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue), allowLossyConversion: false)!

        let keychainQuery = NSMutableDictionary();
        keychainQuery[kSecClassValue as! NSCopying] = kSecClassGenericPasswordValue
        keychainQuery[kSecAttrGenericValue as! NSCopying] = keyData
        keychainQuery[kSecAttrAccountValue as! NSCopying] = keyData
        keychainQuery[kSecAttrServiceValue as! NSCopying] = serviceValue
        keychainQuery[kSecAttrAccessibleValue as! NSCopying] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        keychainQuery[kSecValueData as! NSCopying] = valueData;
        // Delete any existing items
        SecItemDelete(keychainQuery as CFDictionary)
        SecItemAdd(keychainQuery as CFDictionary, nil)
    }

    // MARK: Load

    func load(key: String)->Data {

        let keyData: Data = key.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue), allowLossyConversion: false)!
        let keychainQuery = NSMutableDictionary();
        keychainQuery[kSecClassValue as! NSCopying] = kSecClassGenericPasswordValue
        keychainQuery[kSecAttrGenericValue as! NSCopying] = keyData
        keychainQuery[kSecAttrAccountValue as! NSCopying] = keyData
        keychainQuery[kSecAttrServiceValue as! NSCopying] = serviceValue
        keychainQuery[kSecAttrAccessibleValue as! NSCopying] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        keychainQuery[kSecMatchLimit] = kSecMatchLimitOne
        keychainQuery[kSecReturnPersistentRef] = kCFBooleanTrue

        var result: AnyObject?
        let status = withUnsafeMutablePointer(to: &result) { SecItemCopyMatching(keychainQuery, UnsafeMutablePointer($0)) }

        if status == errSecSuccess {
            if let data = result as! NSData? {
                if let value = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue) {
                    print(value)
                }
                return data as Data;
            }
        }
        return "".data(using: .utf8)!;
    }
}
