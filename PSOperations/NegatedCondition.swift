/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
The file shows how to make an OperationCondition that composes another OperationCondition.
*/

import Foundation

public extension ErrorInformationKey {
    public static var negatedCondition: ErrorInformationKey<OperationCondition> {
        return .init(rawValue: "NegatedCondition")
    }
}

/**
    A simple condition that negates the evaluation of another condition.
    This is useful (for example) if you want to only execute an operation if the 
    network is NOT reachable.
*/
public struct NegatedCondition<T: OperationCondition>: OperationCondition {
    public static var name: String { 
        return "Not<\(T.name)>"
    }
    
    public static var isMutuallyExclusive: Bool {
        return T.isMutuallyExclusive
    }
    
    let condition: T

    public init(condition: T) {
        self.condition = condition
    }
    
    public func dependencyForOperation(_ operation: Operation) -> Foundation.Operation? {
        return condition.dependencyForOperation(operation)
    }
    
    public func evaluateForOperation(_ operation: Operation, completion: @escaping (OperationConditionResult) -> Void) {
        condition.evaluateForOperation(operation) { result in
            switch result {
            case .failed(_):
                // If the composed condition failed, then this one succeeded.
                completion(.satisfied)
            case .satisfied:
                // If the composed condition succeeded, then this one failed.
                let info = ErrorInformation(key: .negatedCondition, value: self.condition)
                let error = ConditionError(condition: self, errorInformation: info)
                
                completion(.failed(error))
            }
        }
    }
}
