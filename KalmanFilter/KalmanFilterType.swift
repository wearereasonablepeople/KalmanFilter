//
//  KalmanFilterType.swift
//  KalmanFilter
//
//  Created by Oleksii on 18/08/16.
//  Copyright © 2016 Oleksii Dykan. All rights reserved.
//

import Foundation

public protocol KalmanInput {
    var transposed: Self { get }
    var inversed: Self { get }
    var additionToUnit: Self { get }
    
    func + (lhs: Self, rhs: Self) -> Self
    func - (lhs: Self, rhs: Self) -> Self
    func * (lhs: Self, rhs: Self) -> Self
}

public protocol KalmanFilterType {
    associatedtype Type: KalmanInput
    
    var stateEstimatePrior: Type { get }
    var errorCovariancePrior: Type { get }
    
    func predict(stateTransitionModel: Type, controlInputModel: Type, controlVector: Type, covarianceOfProcessNoise: Type) -> Self
    func update(measurement: Type, observationModel: Type, covarienceOfObservationNoise: Type) -> Self
}
