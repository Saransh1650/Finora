//
//  LocalStorage.swift
//  med_tech
//
//  Created by Saransh Singhal on 11/8/25.
//

import Foundation

final class LocalStorage {
    
    private static let defaults = UserDefaults.standard
    
    // MARK: - Set value
    static func set(_ key: String, value: Any) {
        defaults.set(value, forKey: key)
    }
    
    // MARK: - Get value with type inference
    static func get<T>(_ key: String, default defaultValue: T? = nil) -> T? {
        if let value = defaults.object(forKey: key) as? T {
            return value
        }
        return defaultValue
    }
    
    // MARK: - Specific Getters
    static func getString(_ key: String, default defaultValue: String? = nil) -> String? {
        return defaults.string(forKey: key) ?? defaultValue
    }
    
    static func getInt(_ key: String, default defaultValue: Int? = nil) -> Int? {
        return defaults.integer(forKey: key) == 0 && defaults.object(forKey: key) == nil
        ? defaultValue
        : defaults.integer(forKey: key)
    }
    
    static func getBool(_ key: String, default defaultValue: Bool? = nil) -> Bool? {
        return defaults.object(forKey: key) == nil
        ? defaultValue
        : defaults.bool(forKey: key)
    }
    
    static func getDouble(_ key: String, default defaultValue: Double? = nil) -> Double? {
        return defaults.object(forKey: key) == nil
        ? defaultValue
        : defaults.double(forKey: key)
    }
    
    static func getList(_ key: String, default defaultValue: [String]? = nil) -> [String]? {
        return defaults.stringArray(forKey: key) ?? defaultValue
    }
    
    // MARK: - Remove
    static func remove(_ key: String) {
        defaults.removeObject(forKey: key)
    }
    
    // MARK: - Clear all
    static func clear() {
        if let bundleId = Bundle.main.bundleIdentifier {
            defaults.removePersistentDomain(forName: bundleId)
        }
    }
}
