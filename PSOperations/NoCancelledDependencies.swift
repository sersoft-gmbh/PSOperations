/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows an example of implementing the OperationCondition protocol.
*/

import Foundation

public extension ErrorInformation.Key {
    public static var cancelledDependencies: ErrorInformation.Key<Array<Foundation.Operation>> {
        return .init(rawValue: "CancelledDependencies")
    }
}

/**
    A condition that specifies that every dependency must have succeeded.
    If any dependency was cancelled, the target operation will be cancelled as 
    well.
*/
public struct NoCancelledDependencies: OperationCondition {
    public static let name = "NoCancelledDependencies"
    public static let isMutuallyExclusive = false
    
    public init() {
        // No op.
    }
    
    public func dependencyForOperation(_ operation: Operation) -> Foundation.Operation? {
        return nil
    }
    
    public func evaluateForOperation(_ operation: Operation, completion: @escaping (OperationConditionResult) -> Void) {
        // Verify that all of the dependencies executed.
        let cancelled = operation.dependencies.filter { $0.isCancelled }

        if !cancelled.isEmpty {
            // At least one dependency was cancelled; the condition was not satisfied.
            let info = ErrorInformation(key: .cancelledDependencies, value: cancelled)
            let error = ConditionError(condition: self, errorInformation: info)
            completion(.failed(error))
        }
        else {
            completion(.satisfied)
        }
    }
}
