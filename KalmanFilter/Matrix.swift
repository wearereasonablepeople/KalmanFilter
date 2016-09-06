//
//  Matrix.swift
//  KalmanFilterTest
//
//  Created by Oleksii on 20/06/16.
//  Copyright © 2016 Oleksii Dykan. All rights reserved.
//

import Foundation

struct Matrix: Equatable {
    // MARK: - Properties
    let rows: Int, columns: Int
    var grid: [Double]
    
    var isSquare: Bool {
        return rows == columns
    }
    
    // MARK: - Initialization
    init(rows: Int, columns: Int) {
        let grid = Array(count: rows * columns, repeatedValue: 0.0)
        self.init(grid: grid, rows: rows, columns: columns)
    }
    
    init(grid: [Double], rows: Int, columns: Int) {
        if rows * columns != grid.count {
            fatalError("Wrong size of the grid")
        }
        
        self.rows = rows
        self.columns = columns
        self.grid = grid
    }
    
    init(vector: [Double]) {
        self.init(grid: vector, rows: vector.count, columns: 1)
    }
    
    init(vectorOf size: Int) {
        self.init(rows: size, columns: 1)
    }
    
    init(squareOfSize size: Int) {
        self.init(rows: size, columns: size)
    }
    
    init(identityOfSize size: Int) {
        self.init(squareOfSize: size)
        for i in 0..<size {
            self[i, i] = 1
        }
    }
    
    init(_ array2d: [[Double]]) {
        self.init(grid: array2d.flatMap({$0}), rows: array2d.count, columns: array2d.first?.count ?? 0)
    }
    
    // MARK: - Public Methods
    func indexIsValid(forRow row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    
    subscript(row: Int, column: Int) -> Double {
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

func == (lhs: Matrix, rhs: Matrix) -> Bool {
    return lhs.rows == rhs.rows && lhs.columns == rhs.columns && lhs.grid == rhs.grid
}

// MARK: -  Matrix as KalmanInput
extension Matrix: KalmanInput {
    /**
     Transposed version of matrix
     
     Compexity: O(n^2)
     */
    var transposed: Matrix {
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
     where **I** - is unit matrix and **A** - is self
     
     **warning** Only for square matrices
     
     Complexity: O(n ^ 2)
     */
    var additionToUnit: Matrix {
        assert(isSquare, "Matrix should be square")
        return Matrix(identityOfSize: rows) - self
    }
    
    var inversed: Matrix {
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
                resultMatrix[i, j] = sign * tM.additionalMatrix(i, column: j).determinant / det
            }
        }
        
        return resultMatrix
    }
    
    var determinant: Double {
        assert(isSquare, "Matrix should be square")
        var result = 0.0
        if rows == 1 {
            result = self[0, 0]
        } else {
            for i in 0..<rows {
                let sign = i % 2 == 0 ? 1.0 : -1.0
                result += sign * self[i, 0] * additionalMatrix(i, column: 0).determinant
            }
        }
        return result
    }
    
    func additionalMatrix(row: Int, column: Int) -> Matrix {
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
    private func operate(with otherMatrix: Matrix, @noescape closure: (Double, Double) -> Double) -> Matrix {
        if rows != otherMatrix.rows || columns != otherMatrix.columns {
            fatalError("Matrixes are not equal")
        }
        
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
func + (lhs: Matrix, rhs: Matrix) -> Matrix {
    return lhs.operate(with: rhs, closure: +)
}

/**
 Naive subtract matrices
 
 Complexity: O(n^2)
 */
func - (lhs: Matrix, rhs: Matrix) -> Matrix {
    return lhs.operate(with: rhs, closure: -)
}


/**
 Naive matrices multiplication
 
 Complexity: O(n^3)
 */
func * (lhs: Matrix, rhs: Matrix) -> Matrix {
    if lhs.columns != rhs.rows {
        fatalError("Cannot multiply matrices")
    }
    
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
func * (lhs: Matrix, rhs: Double) -> Matrix {
    return Matrix(grid: lhs.grid.map({ $0*rhs }), rows: lhs.rows, columns: lhs.columns)
}

func * (lhs: Double, rhs: Matrix) -> Matrix {
    return rhs * lhs
}

// MARK: - CustomStringConvertible for debug output
extension Matrix: CustomStringConvertible {
    var description: String {
        var rows = [String]()
        
        for row in 0..<self.rows {
            let firstIndex = row * columns
            let lastIndex = (row + 1) * columns - 1
            let rowValues = Array(grid[firstIndex ... lastIndex]).map({String($0)})
            
            let leftCharacter: String
            let rightCharacter: String
            
            if self.rows == 1 {
                leftCharacter = "["
                rightCharacter = "]"
            } else if row == 0 {
                leftCharacter = "⎡"
                rightCharacter = "⎤"
            } else if row == self.rows - 1 {
                leftCharacter = "⎣"
                rightCharacter = "⎦"
            } else {
                leftCharacter = "⎮"
                rightCharacter = "⎮"
            }
            
            rows.append(leftCharacter + rowValues.joinWithSeparator(", ") + rightCharacter)
        }
        
        return rows.joinWithSeparator("\n")
    }
}
