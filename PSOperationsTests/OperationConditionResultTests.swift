//
//  OperationConditionResultTests.swift
//  PSOperations
//
//  Created by Matt McMurry on 9/30/15.
//  Copyright © 2015 Pluralsight. All rights reserved.
//

import XCTest
@testable import PSOperations

class OperationConditionResultTests: XCTestCase {
    
    func testOperationConditionResults_satisfied() {
        let sat1 = OperationConditionResult.satisfied
        let sat2 = OperationConditionResult.satisfied
        
        XCTAssertTrue(sat1 == sat2)
    }
    
    func testOperationConditionResults_Failed_SameError() {
        let error = ConditionError(conditionName: "test")
        
        let failed1 = OperationConditionResult.failed(error)
        let failed2 = OperationConditionResult.failed(error)
        
        XCTAssertTrue(failed1 == failed2)
        
    }
    
    func testOperationConditionResults_Failed_DiffError() {
        let failed1 = OperationConditionResult.failed(ConditionError(conditionName: "test1"))
        let failed2 = OperationConditionResult.failed(ConditionError(conditionName: "test2"))
        
        XCTAssertFalse(failed1 == failed2)
        
    }
    
    func testOperationConditionResults_FailedAndSat() {
        let sat = OperationConditionResult.satisfied
        let failed2 = OperationConditionResult.failed(ConditionError(conditionName: "test"))
        
        XCTAssertFalse(sat == failed2)
        
    }
    
    func testOperationConditionResults_HasError() {
        let failed = OperationConditionResult.failed(ConditionError(conditionName: "test"))

        XCTAssertNotNil(failed.error)
    }
    
    func testOperationConditionResults_NoError() {
        let sat = OperationConditionResult.satisfied
        
        XCTAssertNil(sat.error)
    }    
}
