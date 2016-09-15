//
//  XCTestCase+ProgrammerAssertions.swift
//  Assertions
//
//  Created by Mohamed Afifi on 12/20/15.
//  Copyright © 2015 mohamede1945. All rights reserved.
//

/// ### IMPORTANT HOW TO USE ###
/// 1. Drop `ProgrammerAssertions.swift` to the target of your app or framework under test. Just besides your source code.
/// 2. Drop `XCTestCase+ProgrammerAssertions.swift` to your test target. Just besides your test cases.
/// 3. Use `assert`, `assertionFailure`, `precondition`, `preconditionFailure` and `fatalError` normally as you always do.
/// 4. Unit test them with the new methods `expectAssert`, `expectAssertionFailure`, `expectPrecondition`, `expectPreconditionFailure` and `expectFatalError`.
///
/// This file is the unit test assertions.
/// For a complete project example see <https://github.com/mohamede1945/AssertionsTestingExample>

import Foundation
import XCTest
@testable import KalmanFilter

private let noReturnFailureWaitTime = 0.1

public extension XCTestCase {
    
    /**
     Expects an `assert` to be called with a false condition.
     If `assert` not called or the assert's condition is true, the test case will fail.
     
     - parameter expectedMessage: The expected message to be asserted to the one passed to the `assert`. If nil, then ignored.
     - parameter file:            The file name that called the method.
     - parameter line:            The line number that called the method.
     - parameter testCase:        The test case to be executed that expected to fire the assertion method.
     */
    public func expectAssert(
        _ expectedMessage: String? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        testCase: () -> Void
        ) {
        
        expectAssertionReturnFunction("assert", file: file, line: line, function: { (caller) -> () in
            
            Assertions.assertClosure = { condition, message, _, _ in
                caller(condition, message)
            }
            
        }, expectedMessage: expectedMessage, testCase: testCase) { () -> () in
            Assertions.assertClosure = Assertions.swiftAssertClosure
        }
    }
    
    /**
     Expects an `assertionFailure` to be called.
     If `assertionFailure` not called, the test case will fail.
     
     - parameter expectedMessage: The expected message to be asserted to the one passed to the `assertionFailure`. If nil, then ignored.
     - parameter file:            The file name that called the method.
     - parameter line:            The line number that called the method.
     - parameter testCase:        The test case to be executed that expected to fire the assertion method.
     */
    public func expectAssertionFailure(
        _ expectedMessage: String? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        testCase: () -> Void
        ) {
        
        expectAssertionReturnFunction("assertionFailure", file: file, line: line, function: { (caller) -> () in
            
            Assertions.assertionFailureClosure = { message, _, _ in
                caller(false, message)
            }
            
        }, expectedMessage: expectedMessage, testCase: testCase) { () -> () in
            Assertions.assertionFailureClosure = Assertions.swiftAssertionFailureClosure
        }
    }
    
    /**
     Expects an `precondition` to be called with a false condition.
     If `precondition` not called or the precondition's condition is true, the test case will fail.
     
     - parameter expectedMessage: The expected message to be asserted to the one passed to the `precondition`. If nil, then ignored.
     - parameter file:            The file name that called the method.
     - parameter line:            The line number that called the method.
     - parameter testCase:        The test case to be executed that expected to fire the assertion method.
     */
    public func expectPrecondition(
        _ expectedMessage: String? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        testCase: () -> Void
        ) {
        
        expectAssertionReturnFunction("precondition", file: file, line: line, function: { (caller) -> () in
            
            Assertions.preconditionClosure = { condition, message, _, _ in
                caller(condition, message)
            }
            
        }, expectedMessage: expectedMessage, testCase: testCase) { () -> () in
            Assertions.preconditionClosure = Assertions.swiftPreconditionClosure
        }
    }
    
    /**
     Expects an `preconditionFailure` to be called.
     If `preconditionFailure` not called, the test case will fail.
     
     - parameter expectedMessage: The expected message to be asserted to the one passed to the `preconditionFailure`. If nil, then ignored.
     - parameter file:            The file name that called the method.
     - parameter line:            The line number that called the method.
     - parameter testCase:        The test case to be executed that expected to fire the assertion method.
     */
    public func expectPreconditionFailure(
        _ expectedMessage: String? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        testCase: () -> Void
        ) {
        
        expectAssertionNoReturnFunction("preconditionFailure", file: file, line: line, function: { (caller) -> () in
            
            Assertions.preconditionFailureClosure = { message, _, _ in
                caller(message)
            }
            
        }, expectedMessage: expectedMessage, testCase: testCase) { () -> () in
            Assertions.preconditionFailureClosure = Assertions.swiftPreconditionFailureClosure
        }
    }
    
    /**
     Expects an `fatalError` to be called.
     If `fatalError` not called, the test case will fail.
     
     - parameter expectedMessage: The expected message to be asserted to the one passed to the `fatalError`. If nil, then ignored.
     - parameter file:            The file name that called the method.
     - parameter line:            The line number that called the method.
     - parameter testCase:        The test case to be executed that expected to fire the assertion method.
     */
    public func expectFatalError(
        _ expectedMessage: String? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        testCase: () -> Void) {
        
        expectAssertionNoReturnFunction("fatalError", file: file, line: line, function: { (caller) -> () in
            
            Assertions.fatalErrorClosure = { message, _, _ in
                caller(message)
            }
            
        }, expectedMessage: expectedMessage, testCase: testCase) { () -> () in
            Assertions.fatalErrorClosure = Assertions.swiftFatalErrorClosure
        }
    }
    
    // MARK:- Private Methods
    
    fileprivate func expectAssertionReturnFunction(
        _ functionName: String,
        file: StaticString,
        line: UInt,
        function: (_ caller: (Bool, String) -> Void) -> Void,
        expectedMessage: String? = nil,
        testCase: () -> Void,
        cleanUp: @escaping () -> ()
        ) {
        
        let expectation = self.expectation(description: functionName + "-Expectation")
        var assertion: (condition: Bool, message: String)? = nil
        
        function { (condition, message) -> Void in
            assertion = (condition, message)
            expectation.fulfill()
        }
        
        // perform on the same thread since it will return
        testCase()
        
        waitForExpectations(timeout: 0) { _ in
            
            defer {
                // clean up
                cleanUp()
            }
            
            guard let assertion = assertion else {
                XCTFail(functionName + " is expected to be called.", file: file, line: line)
                return
            }
            
            XCTAssertFalse(assertion.condition, functionName + " condition expected to be false", file: file, line: line)
            
            if let expectedMessage = expectedMessage {
                // assert only if not nil
                XCTAssertEqual(assertion.message, expectedMessage, functionName + " called with incorrect message.", file: file, line: line)
            }
        }
    }
    
    fileprivate func expectAssertionNoReturnFunction(
        _ functionName: String,
        file: StaticString,
        line: UInt,
        function: (_ caller: (String) -> Void) -> Void,
        expectedMessage: String? = nil,
        testCase: @escaping () -> Void,
        cleanUp: @escaping () -> ()
        ) {
        
        let expectation = self.expectation(description: functionName + "-Expectation")
        var assertionMessage: String? = nil
        
        function { (message) -> Void in
            assertionMessage = message
            expectation.fulfill()
        }
        
        // act, perform on separate thead because a call to function runs forever
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: testCase)
        
        waitForExpectations(timeout: noReturnFailureWaitTime) { _ in
            
            defer {
                // clean up
                cleanUp()
            }
            
            guard let assertionMessage = assertionMessage else {
                XCTFail(functionName + " is expected to be called.", file: file, line: line)
                return
            }
            
            if let expectedMessage = expectedMessage {
                // assert only if not nil
                XCTAssertEqual(assertionMessage, expectedMessage, functionName + " called with incorrect message.", file: file, line: line)
            }
        }
    }
}
