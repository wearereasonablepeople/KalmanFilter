//
//  MatrixTests.swift
//  KalmanFilterTest
//
//  Created by Oleksii on 20/06/16.
//  Copyright © 2016 Oleksii Dykan. All rights reserved.
//

import XCTest
@testable import KalmanFilter

class MatrixTests: XCTestCase {
    
    func testMatrixIsSquare() {
        XCTAssertTrue(Matrix(identityOfSize: 2).isSquare)
        XCTAssertFalse(Matrix(rows: 3, columns: 1).isSquare)
    }
    
    func testMatrixEquatable() {
        var matrixOne = Matrix(rows: 1, columns: 2)
        var matrixTwo = Matrix(rows: 1, columns: 2)
        
        XCTAssertTrue(matrixOne == matrixTwo)
        XCTAssertTrue(matrixTwo == matrixOne)
        
        matrixOne[0, 0] = 1
        XCTAssertFalse(matrixOne == matrixTwo)
        
        matrixOne[0, 0] = 0
        XCTAssertTrue(matrixTwo == matrixOne)
        
        matrixTwo = Matrix(rows: 2, columns: 1)
        XCTAssertFalse(matrixOne == matrixTwo)
    }
    
    func testMatrixInitialization() {
        let rows = 4
        let columns = 3
        let matrix = Matrix(rows: rows, columns: columns)
        
        XCTAssertEqual(matrix.rows, rows)
        XCTAssertEqual(matrix.columns, columns)
        XCTAssertEqual(matrix.grid.count, rows * columns)
        
        let squareMatrix = Matrix(squareOfSize: rows)
        
        XCTAssertEqual(squareMatrix.rows, rows)
        XCTAssertEqual(squareMatrix.columns, rows)
        XCTAssertEqual(squareMatrix.grid.count, rows * rows)
        
        let identityMatrixSize = 3
        let identityMatrix = Matrix(identityOfSize: identityMatrixSize)
        var identityMatrixProper = Matrix(squareOfSize: identityMatrixSize)
        
        identityMatrixProper[0, 0] = 1
        identityMatrixProper[1, 1] = 1
        XCTAssertNotEqual(identityMatrix, identityMatrixProper)
        
        identityMatrixProper[2, 2] = 1
        XCTAssertEqual(identityMatrix, identityMatrixProper)
        
        let vectorMatrixEmpty = Matrix(vectorOf: 2)
        
        XCTAssertEqual(vectorMatrixEmpty.rows, 2)
        XCTAssertEqual(vectorMatrixEmpty.columns, 1)
        
        let vectorMatrix = Matrix(vector: [2, 1, 3])
        
        XCTAssertEqual(vectorMatrix.rows, 3)
        XCTAssertEqual(vectorMatrix.columns, 1)
        XCTAssertEqual(vectorMatrix[0, 0], 2)
        XCTAssertEqual(vectorMatrix[1, 0], 1)
        XCTAssertEqual(vectorMatrix[2, 0], 3)
        
        let array2d = [[1.0, 0.0], [0.0, 1.0]]
        XCTAssertEqual(Matrix(array2d), Matrix(identityOfSize: 2))
        XCTAssertEqual(Matrix([[2.0], [1], [3]]), vectorMatrix)
    }
    
    func testMatrixCheckForSquare() {
        XCTAssertTrue(Matrix(rows: 2, columns: 2).isSquare)
        XCTAssertTrue(Matrix(squareOfSize: 2).isSquare)
        XCTAssertTrue(Matrix(identityOfSize: 2).isSquare)
        XCTAssertFalse(Matrix(rows: 3, columns: 2).isSquare)
        XCTAssertFalse(Matrix(rows: 2, columns: 3).isSquare)
    }
    
    func testMatrixIndexValidation() {
        let rows = 2
        let columns = 3
        let matrix = Matrix(rows: rows, columns: columns)
        
        XCTAssertTrue(matrix.indexIsValid(forRow: 0, column: 0))
        XCTAssertTrue(matrix.indexIsValid(forRow: rows - 1, column: columns - 1))
        XCTAssertFalse(matrix.indexIsValid(forRow: rows, column: columns))
        XCTAssertFalse(matrix.indexIsValid(forRow: -1, column: -1))
    }
    
    // MARK: Matrix Kalman Filter Extension Tests
    func testMatrixTranspose() {
        let initialMatrix = Matrix([[5, 4], [4, 0], [7, 10], [-1, 8]])
        let transposedMatrixProper = Matrix([[5, 4, 7, -1], [4, 0, 10, 8]])
        XCTAssertEqual(initialMatrix.transposed, transposedMatrixProper)
    }
    
    func testAdditionToUnit() {
        let initialMatrix = Matrix([[4, 7, 1], [-2, 8, 3], [5, -4, 11]])
        let properAddiotionToUnitMatrix = Matrix([[-3, -7, -1], [2, -7, -3], [-5, 4, -10]])
        
        XCTAssertEqual(initialMatrix.additionToUnit, properAddiotionToUnitMatrix)
    }
    
    func testMatrixDeterminant() {
        let initialMatrix = Matrix([[-2, 2, -3], [-1, 1, 3], [2, 0, -1]])
        XCTAssertEqual(initialMatrix.determinant, 18)
    }
    
    func testMatrixInversed() {
        let initialMatrix = Matrix([[1, 2, 3], [0, 1, 4], [5, 6, 0]])
        // Using accelerate causes a very slight precision issue
        let properInversedMatrix = Matrix([[-24.000000000000089, 18.000000000000068, 5.0000000000000178], [20.000000000000075, -15.000000000000055, -4.0000000000000142], [-5.0000000000000195, 4.0000000000000133, 1.0000000000000033]])
        
        XCTAssertEqual(initialMatrix.inversed, properInversedMatrix)
        XCTAssertEqual(Matrix(grid: [2], rows: 1, columns: 1).inversed, Matrix(grid: [1.0/2], rows: 1, columns: 1))
    }
    
    func testMatrixAdditionAndSubtraction() {
        let size = (2, 3)
        let matrixOne = Matrix([[5, 7, 9], [11, -2, -3]])
        let matrixTwo = Matrix([[-8, 4, 9], [6, 3, 2]])
        
        var additionMatrix = Matrix(rows: size.0, columns: size.1)
        var subtractionMatrix = Matrix(rows: size.0, columns: size.1)
        
        additionMatrix[0, 0] = matrixOne[0, 0] + matrixTwo[0, 0]
        additionMatrix[0, 1] = matrixOne[0, 1] + matrixTwo[0, 1]
        additionMatrix[0, 2] = matrixOne[0, 2] + matrixTwo[0, 2]
        additionMatrix[1, 0] = matrixOne[1, 0] + matrixTwo[1, 0]
        additionMatrix[1, 1] = matrixOne[1, 1] + matrixTwo[1, 1]
        additionMatrix[1, 2] = matrixOne[1, 2] + matrixTwo[1, 2]
        
        XCTAssertEqual(matrixOne + matrixTwo, additionMatrix)
        
        subtractionMatrix[0, 0] = matrixOne[0, 0] - matrixTwo[0, 0]
        subtractionMatrix[0, 1] = matrixOne[0, 1] - matrixTwo[0, 1]
        subtractionMatrix[0, 2] = matrixOne[0, 2] - matrixTwo[0, 2]
        subtractionMatrix[1, 0] = matrixOne[1, 0] - matrixTwo[1, 0]
        subtractionMatrix[1, 1] = matrixOne[1, 1] - matrixTwo[1, 1]
        subtractionMatrix[1, 2] = matrixOne[1, 2] - matrixTwo[1, 2]
        
        XCTAssertEqual(matrixOne - matrixTwo, subtractionMatrix)
    }
    
    func testMatrixMultiplication() {
        let matrixOne = Matrix([[3.0, 4, 2]])
        let matrixTwo = Matrix([[13, 9, 7, 15], [8, 7, 4, 6], [6, 4, 0, 3]])
        let multipliedMatrices = Matrix([[83.0, 63, 37, 75]])
        
        XCTAssertEqual(matrixOne * matrixTwo, multipliedMatrices)
    }
    
    func testMatrixMultiplicationByScalar() {
        let matrix = Matrix(grid: [1, 2, 3, 4], rows: 2, columns: 2)
        
        XCTAssertEqual(matrix * 2, Matrix([[2, 4], [6, 8]]))
        XCTAssertEqual(2 * matrix, Matrix([[2, 4], [6, 8]]))
        XCTAssertEqual(matrix * 0.5, Matrix([[0.5, 1], [1.5, 2]]))
    }
    
    func testMatrixStringDescription() {
        let matrix = Matrix([[0.0, 2.0, 3.0, 4.0],
                             [0.0, 2.0, 3.0, 4.0],
                             [0.0, 2.0, 3.0, 4.0]])
        
        let string = "⎛\t0.0\t2.0\t3.0\t4.0\t⎞\n" +
                     "⎜\t0.0\t2.0\t3.0\t4.0\t⎥\n" +
                     "⎝\t0.0\t2.0\t3.0\t4.0\t⎠\n"
        XCTAssertEqual(matrix.description, string)
        XCTAssertEqual(Matrix([[0.0, 2.0, 3.0, 4.0]]).description, "(\t0.0\t2.0\t3.0\t4.0\t)\n")
    }
}
