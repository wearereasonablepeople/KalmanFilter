//
//  DoubleExtensionTests.swift
//  KalmanFilterTest
//
//  Created by Oleksii on 02/07/16.
//  Copyright © 2016 Oleksii Dykan. All rights reserved.
//

import XCTest
@testable import KalmanFilter

class DoubleExtensionTests: XCTestCase {
    
    func testDoubleAsKalmanInput() {
        XCTAssertEqual(5.2.transposed, 5.2)
        XCTAssertEqual(2.0.inversed, 0.5)
        XCTAssertEqual(0.2.additionToUnit, 0.8)
    }
    
}
