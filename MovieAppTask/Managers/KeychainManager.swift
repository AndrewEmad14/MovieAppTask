//
//  KeychainManager.swift
//  MovieAppTask
//
//  Created by Andrew Emad Morris on 21/07/2025.
//"TMBD_key"


import Foundation
import Security

class KeychainManager {

    private static let keyName = "apiKey"

    static func saveAPIKey(service : String ,apiKey: String) throws {
        guard !apiKey.isEmpty else {
            throw KeychainError.emptyKey
        }
        //key must be converted to data
        let keyData = apiKey.data(using: .utf8)!
        // the query needs to have class, service ,account ,value
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: keyName,
            kSecValueData as String: keyData
        ]
        
        // Deletes duplicates
        SecItemDelete(query as CFDictionary)
        //Add key to the defaults
        let status = SecItemAdd(query as CFDictionary, nil)
        //check if there is an error
        if status != errSecSuccess {
            throw KeychainError.saveFailed("Error saving key: \(status)")
        }
    }
    
    static func retrieveAPIKey(service : String) throws -> String? {
        
        // the retreive query needs class, service , accont, return ,match limit
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: keyName,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        //copies the matched item
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        // if the data can be converted to string then return the item
        
        if status == errSecSuccess, let data = item as? Data, let key = String(data: data, encoding: .utf8) {
            return key
        } else if status == errSecItemNotFound {
            return nil
        } else {
            throw KeychainError.retrieveFailed("Error retrieving key: \(status)")
        }
    }
    
    static func deleteAPIKey(service : String) throws {
        // to delete we need class ,service , account
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: keyName
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError.deleteFailed("Error deleting key: \(status)")
        }
    }

    enum KeychainError: Error {
        case emptyKey
        case saveFailed(String)
        case retrieveFailed(String)
        case deleteFailed(String)
    }
}
