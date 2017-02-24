//
//  OperationConditionResultTests.swift
//  PSOperations
//
//  Created by Matt McMurry on 9/30/15.
//  Copyright © 2015 Pluralsight. All rights reserved.
//

import XCTest
@testable import PSOperations

fileprivate extension ConditionError {
    init(name: String, errorInformation: ErrorInformation? = nil) {
        self.conditionName = name
        self.information = errorInformation
    }
}

class OperationConditionResultTests: XCTestCase {
    
    func testOperationConditionResults_satisfied() {
        let sat1 = OperationConditionResult.satisfied
        let sat2 = OperationConditionResult.satisfied
        
        XCTAssertTrue(sat1 == sat2)
    }
    
    func testOperationConditionResults_Failed_SameError() {
        let error = ConditionError(name: "test")
        
        let failed1 = OperationConditionResult.failed(error)
        let failed2 = OperationConditionResult.failed(error)
        
        XCTAssertTrue(failed1 == failed2)
        
    }
    
    func testOperationConditionResults_Failed_DiffError() {
        let failed1 = OperationConditionResult.failed(ConditionError(name: "test1"))
        let failed2 = OperationConditionResult.failed(ConditionError(name: "test2"))
        
        XCTAssertFalse(failed1 == failed2)
        
    }
    
    func testOperationConditionResults_FailedAndSat() {
        let sat = OperationConditionResult.satisfied
        let failed2 = OperationConditionResult.failed(ConditionError(name: "test"))
        
        XCTAssertFalse(sat == failed2)
        
    }
    
    func testOperationConditionResults_HasError() {
        let failed = OperationConditionResult.failed(ConditionError(name: "test"))
        
        XCTAssertNotNil(failed.error)
    }
    
    func testOperationConditionResults_NoError() {
        let sat = OperationConditionResult.satisfied
        
        XCTAssertNil(sat.error)
    }    
}
