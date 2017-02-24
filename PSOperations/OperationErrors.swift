/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file defines the error codes and convenience functions for interacting with Operation-related errors.
*/

public struct ConditionError: Error, Equatable {
    public let conditionName: String
    public let information: ErrorInformation?
    
    public init<Condition: OperationCondition>(condition: Condition, errorInformation: ErrorInformation? = nil) {
        self.conditionName = Condition.name
        self.information = errorInformation
    }
    
    public static func ==(lhs: ConditionError, rhs: ConditionError) -> Bool {
        return lhs.conditionName == rhs.conditionName
    }
}

public struct ErrorInformation {
    fileprivate typealias Key = String
    private var infoDict: Dictionary<Key, Any> = [:]
    
    public var isEmpty: Bool { return infoDict.isEmpty }
    
    public init() {}
    
    public init<T>(key: ErrorInformationKey<T>, value: T) {
        set(value: value, for: key)
    }
    
    public mutating func set<T>(value: T, for key: ErrorInformationKey<T>) {
        infoDict[key.key] = value
    }
    
    public func value<T>(for key: ErrorInformationKey<T>) -> T? {
        return infoDict[key.key] as? T
    }

    // For Swift 3.1
//    public subscript<T>(_ key: ErrorInformationKey<T>) -> T? {
//        return value(for: key)
//    }
}

// TODO: Change this to a nested type `Key` of `ErrorInformation` in Swift 3.1
public struct ErrorInformationKey<T>: RawRepresentable, Hashable {
    public typealias RawValue = String
    
    public let rawValue: RawValue
    public var hashValue: Int { return rawValue.hashValue }
    
    fileprivate var key: ErrorInformation.Key {
        // Allow usages of the same `rawValue` but different Types `T`.
        return "\(rawValue).\(T.self)"
    }
    
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    
    public static func ==<T>(lhs: ErrorInformationKey<T>, rhs: ErrorInformationKey<T>) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
