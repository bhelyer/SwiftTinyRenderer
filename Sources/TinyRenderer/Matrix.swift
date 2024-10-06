public struct Matrix: CustomStringConvertible {
    var m: [[Real]]
    public let rows: Fixed
    public let cols: Fixed

    public init(_ rows: Fixed = 4, _ cols: Fixed = 4) {
        self.rows = rows
        self.cols = cols
        self.m = [[Real]](repeating: [Real](repeating: 0, count: Int(cols)), count: Int(rows))
    }

    public static func identity(dimensions: Fixed) -> Matrix {
        var e = Matrix(dimensions, dimensions)
        for i in 0..<dimensions {
            for j in 0..<dimensions {
                e[i, j] = i == j ? 1 : 0
            }
        }
        return e
    }

    public subscript(row: Fixed, col: Fixed) -> Real {
        get {
            assert(row >= 0 && row < rows && col >= 0 && col < cols)
            return m[Int(row)][Int(col)]
        }
        set(newValue) {
            assert(row >= 0 && row < rows && col >= 0 && col < cols)
            m[Int(row)][Int(col)] = newValue
        }
    }
    
    public static func *(_ lhs: Matrix, _ rhs: Matrix) -> Matrix {
        assert(lhs.cols == rhs.rows)
        var result = Matrix(lhs.rows, rhs.cols)
        for i in 0..<lhs.rows {
            for j in 0..<rhs.cols {
                result[i, j] = 0
                for k in 0..<lhs.cols {
                    result[i, j] += lhs[i, k] * rhs[k, j]
                }
            }
        }
        return result
    }
    
    public func transpose() -> Matrix {
        var result = Matrix(cols, rows)
        for i in 0..<rows {
            for j in 0..<cols {
                result[j, i] = self[i, j]
            }
        }
        return result
    }
    
    public func inverse() -> Matrix {
        assert(rows == cols)

        // Augmenting the square matrix with the identity matrix
        // of the same dimensions a => [ai]
        var result = Matrix(rows, cols * 2)
        for i in 0..<rows {
            for j in 0..<cols {
                result[i, j] = self[i, j]
            }
        }
        for i in 0..<rows {
            result[i, i + cols] = 1
        }

        // First pass.
        for i in 0..<rows - 1 {
            // Normalise the first row.
            var j = result.cols - 1
            while j >= 0 {
                result[i, j] /= result[i, i]
                j -= 1
            }
            for k in i + 1..<rows {
                let coeff = result[k, i]
                for j in 0..<result.cols {
                    result[k, j] -= result[i, j] * coeff
                }
            }
        }
        
        // Normalise the last row.
        var j = result.cols - 1
        while j >= rows - 1 {
            result[rows - 1, j] /= result[rows - 1, rows - 1]
            j -= 1
        }
        
        // Second pass.
        var i = rows - 1
        while i > 0 {
            var k = i - 1
            while k >= 0 {
                let coeff = result[k, i]
                for j in 0..<result.cols {
                    result[k, j] -= result[i, j] * coeff
                }
                k -= 1
            }
            i -= 1
        }
        
        // Cut the identity matrix back.
        var truncate = Matrix(rows, cols)
        for i in 0..<rows {
            for j in 0..<cols {
                truncate[i, j] = result[i, j + cols]
            }
        }
        return truncate
    }
    
    public var description: String {
        var result: String = ""
        for i in 0..<rows {
            for j in 0..<cols {
                result += "\(self[i, j])"
                if j < cols - 1 {
                    result += "\t"
                }
            }
            result += "\n"
        }
        return result
    }
}
