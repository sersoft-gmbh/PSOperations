//
//  ErrorInformationTests.swift
//  PSOperations
//
//  Created by Florian Friedrich on 24/02/2017.
//  Copyright © 2017 Pluralsight. All rights reserved.
//

import XCTest
@testable import PSOperations

fileprivate extension ErrorInformationKey {
    static var stringTest: ErrorInformationKey<String> {
        return .init(rawValue: "stringTest")
    }
    
    static var boolTest: ErrorInformationKey<Bool> {
        return .init(rawValue: "boolTest")
    }
    
    static var sameKeyBool: ErrorInformationKey<Bool> {
        return .init(rawValue: "sameKey")
    }
    
    static var sameKeyString: ErrorInformationKey<String> {
        return .init(rawValue: "sameKey")
    }
    
    static var inexistent: ErrorInformationKey<Any> {
        return .init(rawValue: "inexistent")
    }
}

class ErrorInformationTests: XCTestCase {
    
    func testErrorInformationKeyEquality() {
        let key1: ErrorInformationKey<Bool> = .boolTest
        let key2: ErrorInformationKey<Bool> = .boolTest
        
        XCTAssertTrue(key1 == key2)
        XCTAssertEqual(key1.hashValue, key2.hashValue)
        XCTAssertEqual(key1.rawValue, key2.rawValue)
    }
    
    func testErrorInformationKeyInequality() {
        let key1: ErrorInformationKey<Bool> = .boolTest
        let key2: ErrorInformationKey<String> = .stringTest
        
        // Direct comparison is already prohibited by compiler due to different generic types.
        // XCTAssertFalse(key1 == key2)
        XCTAssertNotEqual(key1.hashValue, key2.hashValue)
        XCTAssertNotEqual(key1.rawValue, key2.rawValue)
    }
    
    func testErrorInformationIsEmpty() {
        let info1 = ErrorInformation()
        let info2 = ErrorInformation(key: .boolTest, value: true)
        
        XCTAssertTrue(info1.isEmpty)
        XCTAssertFalse(info2.isEmpty)
    }
    
    func testErrorInformationStoringValues() {
        let key1: ErrorInformationKey<Bool> = .boolTest
        let key2: ErrorInformationKey<String> = .stringTest
        let value1 = true
        let value2 = "test"
        var info = ErrorInformation(key: key1, value: value1)
        info.set(value: value2, for: key2)
        
        let retrievedValue1 = info.value(for: key1)
        let retrievedValue2 = info.value(for: key2)
        let retrievedInexistentValue = info.value(for: .inexistent)
        XCTAssertNil(retrievedInexistentValue)
        XCTAssertNotNil(retrievedValue1)
        XCTAssertNotNil(retrievedValue2)
        XCTAssertEqual(retrievedValue1, value1)
        XCTAssertEqual(retrievedValue2, value2)
    }
    
    func testErrorInformationStoringValuesWithSameRawValue() {
        let key1: ErrorInformationKey<Bool> = .sameKeyBool
        let key2: ErrorInformationKey<String> = .sameKeyString
        let value1 = true
        let value2 = "test"
        var info = ErrorInformation(key: key1, value: value1)
        info.set(value: value2, for: key2)
        
        let retrievedValue1 = info.value(for: key1)
        let retrievedValue2 = info.value(for: key2)
        let retrievedInexistentValue = info.value(for: .inexistent)
        XCTAssertNil(retrievedInexistentValue)
        XCTAssertNotNil(retrievedValue1)
        XCTAssertNotNil(retrievedValue2)
        XCTAssertEqual(retrievedValue1, value1)
        XCTAssertEqual(retrievedValue2, value2)
    }
}
