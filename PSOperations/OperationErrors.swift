/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file defines the error codes and convenience functions for interacting with Operation-related errors.
*/

public struct ConditionError: Error, Equatable {
    public let conditionName: String
    public let information: ErrorInformation?

    internal init(conditionName: String, errorInformation: ErrorInformation? = nil) {
        self.conditionName = conditionName
        self.information = errorInformation
    }
    
    public init<Condition: OperationCondition>(condition: Condition, errorInformation: ErrorInformation? = nil) {
        self.init(conditionName: Condition.name, errorInformation: errorInformation)
    }
    
    public static func ==(lhs: ConditionError, rhs: ConditionError) -> Bool {
        return lhs.conditionName == rhs.conditionName
    }
}

public struct ErrorInformation {
    fileprivate typealias RawKey = String
    
    private var infoDict: Dictionary<RawKey, Any> = [:]
    
    public var isEmpty: Bool { return infoDict.isEmpty }
    
    public init() {}

    public init<T>(key: Key<T>, value: T) {
        self[key] = value
    }
    
    public mutating func set<T>(value: T, for key: Key<T>) {
        self[key] = value
    }
    
    public func value<T>(for key: Key<T>) -> T? {
        return self[key]
    }

    public subscript<T>(_ key: ErrorInformation.Key<T>) -> T? {
        get {
            return infoDict[key.rawKey] as? T
        }
        set {
            infoDict[key.rawKey] = newValue
        }
    }
}

public extension ErrorInformation {
    public struct Key<T>: RawRepresentable, Hashable {
        public typealias RawValue = String
        
        public let rawValue: RawValue
        
        fileprivate var rawKey: ErrorInformation.RawKey {
            // Allow usages of the same `rawValue` but different Types `T`.
            return "\(rawValue).\(T.self)"
        }
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
}
