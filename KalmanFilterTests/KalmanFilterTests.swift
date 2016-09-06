//
//  KalmanFilterTests.swift
//  KalmanFilterTests
//
//  Created by Oleksii on 17/08/16.
//  Copyright © 2016 Oleksii Dykan. All rights reserved.
//

import XCTest
@testable import KalmanFilter

class KalmanFilterTests: XCTestCase {
    
    func testKalmanFilter2D() {
        let measurements = [1.0, 2.0, 3.0]
        let accuracy = 0.00001
        
        let x = Matrix(vector: [0, 0])
        let P = Matrix(grid: [1000, 0, 0, 1000], rows: 2, columns: 2)
        let B = Matrix(identityOfSize: 2)
        let u = Matrix(vector: [0, 0])
        let F = Matrix(grid: [1, 1, 0, 1], rows: 2, columns: 2)
        let H = Matrix(grid: [1, 0], rows: 1, columns: 2)
        let R = Matrix(grid: [1], rows: 1, columns: 1)
        let Q = Matrix(rows: 2, columns: 2)
        
        var kalmanFilter = KalmanFilter(stateEstimatePrior: x, errorCovariancePrior: P)
        
        for measurement in measurements {
            let z = Matrix(grid: [measurement], rows: 1, columns: 1)
            kalmanFilter = kalmanFilter.update(z, observationModel: H, covarienceOfObservationNoise: R)
            kalmanFilter = kalmanFilter.predict(F, controlInputModel: B, controlVector: u, covarianceOfProcessNoise: Q)
        }
        
        let resultX = Matrix(vector: [3.9996664447958645, 0.9999998335552873])
        let resultP = Matrix(grid: [2.3318904241194827, 0.9991676099921091, 0.9991676099921067, 0.49950058263974184], rows: 2, columns: 2)
        
        XCTAssertEqualWithAccuracy(kalmanFilter.stateEstimatePrior[0, 0], resultX[0, 0], accuracy: accuracy)
        XCTAssertEqualWithAccuracy(kalmanFilter.stateEstimatePrior[1, 0], resultX[1, 0], accuracy: accuracy)
        XCTAssertEqualWithAccuracy(kalmanFilter.errorCovariancePrior[0, 0], resultP[0, 0], accuracy: accuracy)
        XCTAssertEqualWithAccuracy(kalmanFilter.errorCovariancePrior[0, 1], resultP[0, 1], accuracy: accuracy)
        XCTAssertEqualWithAccuracy(kalmanFilter.errorCovariancePrior[1, 0], resultP[1, 0], accuracy: accuracy)
        XCTAssertEqualWithAccuracy(kalmanFilter.errorCovariancePrior[1, 1], resultP[1, 1], accuracy: accuracy)
    }
    
}
