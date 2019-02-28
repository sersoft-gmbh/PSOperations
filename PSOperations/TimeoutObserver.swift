/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows how to implement the OperationObserver protocol.
*/

import Foundation

/**
    `TimeoutObserver` is a way to make an `Operation` automatically time out and 
    cancel after a specified time interval.
*/
public class TimeoutObserver: OperationObserver {
    // MARK: Properties

    private let timeout: TimeInterval

    // MARK: Initialization

    public init(timeout: TimeInterval) {
        self.timeout = timeout
    }

    // MARK: OperationObserver

    public func operationDidStart(_ operation: Operation) {
        // When the operation starts, queue up a block to cause it to time out.
        let when = DispatchTime.now() + timeout

        DispatchQueue.global(qos: operation.qualityOfService).asyncAfter(deadline: when) {
            /*
                Cancel the operation if it hasn't finished and hasn't already 
                been cancelled.
            */
            if !operation.isFinished && !operation.isCancelled {
                operation.cancelWithError(TimeoutError(timeout: self.timeout))
            }
        }
    }

    public func operationDidCancel(_ operation: Operation) {
        // No op.
    }

    public func operation(_ operation: Operation, didProduceOperation newOperation: Foundation.Operation) {
        // No op.
    }

    public func operationDidFinish(_ operation: Operation, errors: [Error]) {
        // No op.
    }
}

public extension TimeoutObserver {
    public struct TimeoutError: Error, Equatable {
        public let timeout: TimeInterval
        
        fileprivate init(timeout: TimeInterval) {
            self.timeout = timeout
        }
    }
}
