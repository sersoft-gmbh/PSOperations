//
//  ConditionErrorTests.swift
//  PSOperations
//
//  Created by Matt McMurry on 10/1/15.
//  Copyright © 2015 Pluralsight. All rights reserved.
//

import XCTest
@testable import PSOperations

class ConditionErrorTests: XCTestCase {
    
    struct TestCondition: OperationCondition {
        static let name = "TestCondition"
        static let isMutuallyExclusive = false
        
        init() {}
        
        func dependencyForOperation(_ operation: PSOperation) -> Foundation.Operation? {
            return nil
        }
        
        func evaluateForOperation(_ operation: PSOperation, completion: @escaping (OperationConditionResult) -> Void) {
            completion(.satisfied)
        }
    }
    
    func testConditionErrorConditionName() {
        let condition = TestCondition()
        let conditionError = ConditionError(condition: condition)
        
        XCTAssertEqual(conditionError.conditionName, TestCondition.name)
    }
    
    func testConditionErrorEquality() {
        let condition = TestCondition()
        let conditionError1 = ConditionError(condition: condition)
        let conditionError2 = ConditionError(condition: condition)
        
        XCTAssertTrue(conditionError1 == conditionError2)
    }

    func testConditionErrorEqualityWithErrorInformation() {
        let condition = TestCondition()
        let info = ErrorInformation()
        let conditionError1 = ConditionError(condition: condition, errorInformation: info)
        let conditionError2 = ConditionError(condition: condition)
        
        XCTAssertTrue(conditionError1 == conditionError2)
    }
}
