public typealias Fixed = Int32
public typealias Real = Float

public struct Vec2<T: Numeric>: CustomStringConvertible {
    typealias VecType = T

    public var x: T
    public var y: T
    
    public subscript(componentIndex: Int) -> T {
        get {
            assert(componentIndex == 0 || componentIndex == 1, "Vec2: bad index")
            if componentIndex == 0 {
                return x
            } else if componentIndex == 1 {
                return y
            } else {
                return 0
            }
        }
        set(newValue) {
            assert(componentIndex == 0 || componentIndex == 1, "Vec2: bad index")
            if componentIndex == 0 {
                x = newValue
            } else if componentIndex == 1 {
                y = newValue
            }
        }
    }
    
    public init() {
        self.x = 0
        self.y = 0
    }
    
    public init(_ x: T, _ y: T) {
        self.x = x
        self.y = y
    }
    
    public static func +(left: Vec2, right: Vec2) -> Vec2 {
        return Vec2(left.x + right.x, left.y + right.y)
    }
    
    public static func -(left: Vec2, right: Vec2) -> Vec2 {
        return Vec2(left.x - right.x, left.y - right.y)
    }
    
    public var description: String {
        return "(\(x), \(y))"
    }
}

public func *(left: Vec2r, right: Real) -> Vec2r {
    return Vec2r(left.x * right, left.y * right)
}

public struct Vec3<T: FloatingPoint>: CustomStringConvertible {
    public var x: T
    public var y: T
    public var z: T

    public subscript(componentIndex: Int) -> T {
        get {
            assert(componentIndex >= 0 && componentIndex <= 2, "Vec3: bad index")
            if componentIndex == 0 {
                return x
            } else if componentIndex == 1 {
                return y
            } else if componentIndex == 2 {
                return z
            } else {
                return 0
            }
        }
        set(newValue) {
            assert(componentIndex >= 0 && componentIndex <= 2, "Vec3: bad index")
            if componentIndex == 0 {
                x = newValue
            } else if componentIndex == 1 {
                y = newValue
            } else if componentIndex == 2 {
                z = newValue
            }
        }
    }

    public init() {
        x = 0
        y = 0
        z = 0
    }

    public init(_ x: T, _ y: T, _ z: T) {
        self.x = x
        self.y = y
        self.z = z
    }

    public static func +(left: Vec3, right: Vec3) -> Vec3 {
        return Vec3(left.x + right.x, left.y + right.y, left.z + right.z)
    }

    public static func -(left: Vec3, right: Vec3) -> Vec3 {
        return Vec3(left.x - right.x, left.y - right.y, left.z - right.z)
    }

    public static func *(left: Vec3, right: T) -> Vec3 {
        return Vec3(left.x * right, left.y * right, left.z * right)
    }

    /// Return the length of this vector.
    public var length: T {
        let xx = x * x
        let yy = y * y
        let zz = z * z
        return (xx + yy + zz).squareRoot()
    }

    /// Transform this vector so its length is `length` (default 1).
    public mutating func normalise(toLength l: T = 1) {
        self = self * (l / length)
    }

    public var description: String {
        return "(\(x), \(y), \(z))"
    }
}

/// Calculate the cross product of two vectors.
public func cross(_ left: Vec3r, _ right: Vec3r) -> Vec3r {
    return Vec3r(left.y * right.z - left.z * right.y,
                 left.z * right.x - left.x * right.z,
                 left.x * right.y - left.y * right.x)
}

/// Calculate the dot product of two vectors.
public func dot(_ left: Vec3r, _ right: Vec3r) -> Real {
    return left.x * right.x + left.y * right.y + left.z * right.z
}

public typealias Vec2i = Vec2<Fixed>
public typealias Vec2r = Vec2<Real>
public typealias Vec3r = Vec3<Real>
