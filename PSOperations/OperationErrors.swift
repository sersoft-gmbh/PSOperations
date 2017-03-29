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
    fileprivate typealias RawKey = String
    
    private var infoDict: Dictionary<RawKey, Any> = [:]
    
    public var isEmpty: Bool { return infoDict.isEmpty }
    
    public init() {}
    
    #if swift(>=3.1)
    public init<T>(key: Key<T>, value: T) {
        set(value: value, for: key)
    }
    
    public mutating func set<T>(value: T, for key: Key<T>) {
        infoDict[key.rawKey] = value
    }
    
    public func value<T>(for key: Key<T>) -> T? {
        return infoDict[key.rawKey] as? T
    }
    #else
    public init<T>(key: ErrorInformationKey<T>, value: T) {
        set(value: value, for: key)
    }
    
    public mutating func set<T>(value: T, for key: ErrorInformationKey<T>) {
        infoDict[key.rawKey] = value
    }
    
    public func value<T>(for key: ErrorInformationKey<T>) -> T? {
        return infoDict[key.rawKey] as? T
    }
    #endif

    // For Swift 4.0
//    public subscript<T>(_ key: ErrorInformation.Key<T>) -> T? {
//        return value(for: key)
//    }
}

#if swift(>=3.1)
public extension ErrorInformation {
    @available(swift, introduced: 3.1)
    public struct Key<T>: RawRepresentable, Hashable {
        public typealias RawValue = String
        
        public let rawValue: RawValue
        public var hashValue: Int { return rawValue.hashValue }
        
        fileprivate var rawKey: ErrorInformation.RawKey {
            // Allow usages of the same `rawValue` but different Types `T`.
            return "\(rawValue).\(T.self)"
        }
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        
        public static func ==<T>(lhs: Key<T>, rhs: Key<T>) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
    }
}
#endif

#if swift(>=3.1)
@available(swift, obsoleted: 3.1, message: "Use ErrorInformation.Key")
public typealias ErrorInformationKey = ErrorInformation.Key
#else
public struct ErrorInformationKey<T>: RawRepresentable, Hashable {
    public typealias RawValue = String
    
    public let rawValue: RawValue
    public var hashValue: Int { return rawValue.hashValue }
    
    fileprivate var rawKey: ErrorInformation.RawKey {
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
#endif
