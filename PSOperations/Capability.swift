//
//  Capability.swift
//  PSOperations
//
//  Created by Dev Team on 10/4/15.
//  Copyright © 2015 Pluralsight. All rights reserved.
//

import Foundation

public struct CapabilityError: Error, Equatable {
    public let capabilityName: String
    public let reason: Reason
    
    public init<Capability: CapabilityType>(capability: Capability, reason: Reason) {
        self.capabilityName = Capability.name
        self.reason = reason
    }
    
    public init?<Capability: CapabilityType>(capability: Capability, status: CapabilityStatus) {
        guard let reason = status.errorReason else { return nil }
        self.capabilityName = Capability.name
        self.reason = reason
    }
    
    public static func ==(lhs: CapabilityError, rhs: CapabilityError) -> Bool {
        return lhs.capabilityName == rhs.capabilityName && lhs.reason == rhs.reason
    }
}

public extension CapabilityError {
    public enum Reason: Equatable {
        case notDetermined
        case notAvailable
        case denied
        case failed(Error)
        
        public static func ==(lhs: Reason, rhs: Reason) -> Bool {
            switch (lhs, rhs) {
                case (.notDetermined, .notDetermined),
                     (.notAvailable, .notAvailable),
                     (.denied, .denied):
                    return true
            case (.failed(_ /*let lhsError*/), .failed(_ /*let rhsError*/)):
                return true
                // We could compare based on the errors bridged to NSError. But it would be rather unsafe.
//                return (lhsError as NSError) == (rhsError as NSError)
            default:
                return false
            }
        }
    }
}

#if swift(>=3.1)
public extension ErrorInformation.Key {
    public static var capabilityError: ErrorInformation.Key<CapabilityError> {
        return .init(rawValue: "CapabilityError")
    }
}
#else
public extension ErrorInformationKey {
    public static var capabilityError: ErrorInformationKey<CapabilityError> {
        return .init(rawValue: "CapabilityError")
    }
}
#endif

public enum CapabilityStatus: Equatable {
    /// The capability has not been requested yet
    case notDetermined
    
    /// The capability has been requested and approved
    case authorized
    
    /// The capability has been requested but was denied by the user
    case denied
    
    /// The capability is not available (perhaps due to restrictions, or lack of support)
    case notAvailable
    
    /// There was an error requesting the status of the capability
    case error(Error)
    
    public static func ==(lhs: CapabilityStatus, rhs: CapabilityStatus) -> Bool {
        switch (lhs, rhs) {
        case (.notDetermined, .notDetermined),
             (.denied, .denied),
             (.authorized, .authorized),
             (.notAvailable, .notAvailable):
            return true
        case (.error(_ /*let lhsError*/), .error(_ /*let rhsError*/)):
            return true
            // We could compare based on the errors bridged to NSError. But it would be rather unsafe.
        //                return (lhsError as NSError) == (rhsError as NSError)
        default:
            return false
        }
    }
}

public protocol CapabilityType {
    static var name: String { get }
    
    /// Retrieve the status of the capability.
    /// This method is called from the main queue.
    func requestStatus(_ completion: @escaping (CapabilityStatus) -> Void)
    
    /// Request authorization for the capability.
    /// This method is called from the main queue, and only if the
    /// capability's status is "NotDetermined"
    func authorize(_ completion: @escaping (CapabilityStatus) -> Void)
}

/// A condition for verifying and/or requesting a certain capability
public struct Capability<C: CapabilityType>: OperationCondition {
    
    public static var name: String { return "Capability<\(C.name)>" }
    public static var isMutuallyExclusive: Bool { return true }
    
    fileprivate let capability: C
    fileprivate let shouldRequest: Bool
    
    public init(_ capability: C, requestIfNecessary: Bool = true) {
        self.capability = capability
        self.shouldRequest = requestIfNecessary
    }
    
    public func dependencyForOperation(_ operation: Operation) -> Foundation.Operation? {
        guard shouldRequest == true else { return nil }
        return AuthorizeCapability(capability: capability)
    }
    
    public func evaluateForOperation(_ operation: Operation, completion: @escaping (OperationConditionResult) -> Void) {
        DispatchQueue.main.async {
            self.capability.requestStatus { status in
                if let error = CapabilityError(capability: self.capability, status: status) {
                    let info = ErrorInformation(capabilityError: error)
                    let conditionError = ConditionError(condition: self, errorInformation: info)
                    completion(.failed(conditionError))
                } else {
                    completion(.satisfied)
                }
            }
        }
    }
}

fileprivate class AuthorizeCapability<C: CapabilityType>: Operation {
    fileprivate let capability: C
    
    init(capability: C) {
        self.capability = capability
        super.init()
        addCondition(AlertPresentation())
        addCondition(MutuallyExclusive<C>())
    }
    
    fileprivate override func execute() {
        DispatchQueue.main.async {
            self.capability.requestStatus { status in
                if case .notDetermined = status {
                    self.requestAuthorization()
                } else  {
                    self.finishWithError(CapabilityError(capability: self.capability, status: status))
                }
            }
        }
    }
    
    fileprivate func requestAuthorization() {
        DispatchQueue.main.async {
            self.capability.authorize { status in
                self.finishWithError(CapabilityError(capability: self.capability, status: status))
            }
        }
    }
}

fileprivate extension CapabilityStatus {
    var errorReason: CapabilityError.Reason? {
        switch self {
        case .notDetermined: return .notDetermined
        case .denied: return .denied
        case .notAvailable: return .notAvailable
        case .error(let error): return .failed(error)
        case .authorized: return nil
        }
    }
}

fileprivate extension ErrorInformation {
    init(capabilityError: CapabilityError) {
        self.init(key: .capabilityError, value: capabilityError)
    }
}
