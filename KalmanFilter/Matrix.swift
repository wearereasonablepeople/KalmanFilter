//
//  Matrix.swift
//  KalmanFilterTest
//
//  Created by Oleksii on 20/06/16.
//  Copyright © 2016 Oleksii Dykan. All rights reserved.
//

import Foundation

public struct Matrix: Equatable {
    // MARK: - Properties
    public let rows: Int, columns: Int
    public var grid: [Double]
    
    var isSquare: Bool {
        return rows == columns
    }
    
    // MARK: - Initialization
    
    /**
     Initialization of matrix with rows * columns
     size where all the elements are set to 0.0
     
     - parameter rows: number of rows in matrix
     - parameter columns: number of columns in matrix
     */
    public init(rows: Int, columns: Int) {
        let grid = Array(repeating: 0.0, count: rows * columns)
        self.init(grid: grid, rows: rows, columns: columns)
    }
    
    /**
     Initialization with grid that contains all the
     elements of matrix with given matrix size
     
     - parameter grid: array of matrix elements. **warning**
     Should be of rows * column size.
     - parameter rows: number of rows in matrix
     - parameter columns: number of columns in matrix
     */
    public init(grid: [Double], rows: Int, columns: Int) {
        assert(rows * columns == grid.count, "grid size should be rows * column size")
        self.rows = rows
        self.columns = columns
        self.grid = grid
    }
    
    /**
     Initialization of 
     [column vector](https://en.wikipedia.org/wiki/Row_and_column_vectors)
     with given array. Number of
     elements in array equals to number of rows in vector.
     
     - parameter vector: array with elements of vector
    */
    public init(vector: [Double]) {
        self.init(grid: vector, rows: vector.count, columns: 1)
    }
    
    /**
     Initialization of 
     [column vector](https://en.wikipedia.org/wiki/Row_and_column_vectors)
     with given number of rows. Every element is assign to 0.0
     
     - parameter size: vector size
     */
    public init(vectorOf size: Int) {
        self.init(rows: size, columns: 1)
    }
    
    /**
     Initialization of square matrix with given size. Number of
     elements in array equals to size * size. Every elements is
     assigned to 0.0
     
     - parameter size: number of rows and columns in matrix
     */
    public init(squareOfSize size: Int) {
        self.init(rows: size, columns: size)
    }
    
    /**
     Initialization of 
     [identity matrix](https://en.wikipedia.org/wiki/Identity_matrix)
     of given sizen
     
     - parameter size: number of rows and columns in identity matrix
     */
    public init(identityOfSize size: Int) {
        self.init(squareOfSize: size)
        for i in 0..<size {
            self[i, i] = 1
        }
    }
    
    /**
     Convenience initialization from 2D array
     
     - parameter array2d: 2D array representation of matrix
     */
    public init(_ array2d: [[Double]]) {
        self.init(grid: array2d.flatMap({$0}), rows: array2d.count, columns: array2d.first?.count ?? 0)
    }
    
    // MARK: - Public Methods
    /**
     Determines whether element exists at specified row and
     column
     
     - parameter row: row index of element
     - parameter column: column index of element
     - returns: bool indicating whether spicified indeces are valid
     */
    public func indexIsValid(forRow row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    
    public subscript(row: Int, column: Int) -> Double {
        get {
            assert(indexIsValid(forRow: row, column: column), "Index out of range")
            return grid[(row * columns) + column]
        }
        set {
            assert(indexIsValid(forRow: row, column: column), "Index out of range")
            grid[(row * columns) + column] = newValue
        }
    }
}

// MARK: - Equatable

public func == (lhs: Matrix, rhs: Matrix) -> Bool {
    return lhs.rows == rhs.rows && lhs.columns == rhs.columns && lhs.grid == rhs.grid
}

// MARK: -  Matrix as KalmanInput
extension Matrix: KalmanInput {
    /**
     [Transposed](https://en.wikipedia.org/wiki/Transpose)
     version of matrix
     
     Compexity: O(n^2)
     */
    public var transposed: Matrix {
        var resultMatrix = Matrix(rows: columns, columns: rows)
        for i in 0..<rows {
            for j in 0..<columns {
                resultMatrix[j, i] = self[i, j]
            }
        }
        return resultMatrix
    }
    
    /**
     Addition to Unit in form: **I - A**
     where **I** - is 
     [identity matrix](https://en.wikipedia.org/wiki/Identity_matrix) 
     and **A** - is self
     
     **warning** Only for square matrices
     
     Complexity: O(n ^ 2)
     */
    public var additionToUnit: Matrix {
        assert(isSquare, "Matrix should be square")
        return Matrix(identityOfSize: rows) - self
    }
    
    /**
     Inversed matrix if
     [it is invertible](https://en.wikipedia.org/wiki/Invertible_matrix)
     */
    public var inversed: Matrix {
        assert(isSquare, "Matrix should be square")
        
        if rows == 1 {
            return Matrix(grid: [1/self[0, 0]], rows: 1, columns: 1)
        }
        
        var resultMatrix = Matrix(squareOfSize: rows)
        let tM = transposed
        let det = determinant
        for i in 0..<rows {
            for j in 0..<rows {
                let sign = (i + j) % 2 == 0 ? 1.0: -1.0
                resultMatrix[i, j] = sign * tM.additionalMatrix(row: i, column: j).determinant / det
            }
        }
        
        return resultMatrix
    }
    
    /**
     [Matrix determinant](https://en.wikipedia.org/wiki/Determinant)
     */
    public var determinant: Double {
        assert(isSquare, "Matrix should be square")
        var result = 0.0
        if rows == 1 {
            result = self[0, 0]
        } else {
            for i in 0..<rows {
                let sign = i % 2 == 0 ? 1.0 : -1.0
                result += sign * self[i, 0] * additionalMatrix(row: i, column: 0).determinant
            }
        }
        return result
    }
    
    public func additionalMatrix(row: Int, column: Int) -> Matrix {
        assert(indexIsValid(forRow: row, column: column), "Invalid arguments")
        var resultMatrix = Matrix(rows: rows - 1, columns: columns - 1)
        for i in 0..<rows {
            if i == row {
                continue
            }
            for j in 0..<columns {
                if j == column {
                    continue
                }
                let resI = i < row ? i : i - 1
                let resJ = j < column ? j : j - 1
                resultMatrix[resI, resJ] = self[i, j]
            }
        }
        return resultMatrix
    }
    
    // MARK: - Private methods
    fileprivate func operate(with otherMatrix: Matrix, closure: (Double, Double) -> Double) -> Matrix {
        assert(rows == otherMatrix.rows && columns == otherMatrix.columns, "Matrices should be of equal size")
        var resultMatrix = Matrix(rows: rows, columns: columns)
        
        for i in 0..<rows {
            for j in 0..<columns {
                resultMatrix[i, j] = closure(self[i, j], otherMatrix[i, j])
            }
        }
        
        return resultMatrix
    }
}

/**
 Naive add matrices
 
 Complexity: O(n^2)
 */
public func + (lhs: Matrix, rhs: Matrix) -> Matrix {
    return lhs.operate(with: rhs, closure: +)
}

/**
 Naive subtract matrices
 
 Complexity: O(n^2)
 */
public func - (lhs: Matrix, rhs: Matrix) -> Matrix {
    return lhs.operate(with: rhs, closure: -)
}


/**
 Naive matrices multiplication
 
 Complexity: O(n^3)
 */
public func * (lhs: Matrix, rhs: Matrix) -> Matrix {
    assert(lhs.columns == rhs.rows, "Left matrix columns should be the size of right matrix's rows")
    var resultMatrix = Matrix(rows: lhs.rows, columns: rhs.columns)
    
    for i in 0..<resultMatrix.rows {
        for j in 0..<resultMatrix.columns {
            var currentValue = 0.0
            
            for k in 0..<lhs.columns {
                currentValue += lhs[i, k] * rhs[k, j]
            }
            
            resultMatrix[i, j] = currentValue
        }
    }
    
    return resultMatrix
}

// MARK: - Nice additional methods
public func * (lhs: Matrix, rhs: Double) -> Matrix {
    return Matrix(grid: lhs.grid.map({ $0*rhs }), rows: lhs.rows, columns: lhs.columns)
}

public func * (lhs: Double, rhs: Matrix) -> Matrix {
    return rhs * lhs
}

// MARK: - CustomStringConvertible for debug output
extension Matrix: CustomStringConvertible {
    public var description: String {
        var description = ""
        
        for i in 0..<rows {
            let contents = (0..<columns).map{"\(self[i, $0])"}.joined(separator: "\t")
            
            switch (i, rows) {
            case (0, 1):
                description += "(\t\(contents)\t)"
            case (0, _):
                description += "⎛\t\(contents)\t⎞"
            case (rows - 1, _):
                description += "⎝\t\(contents)\t⎠"
            default:
                description += "⎜\t\(contents)\t⎥"
            }
            
            description += "\n"
        }
        
        return description
    }
}
