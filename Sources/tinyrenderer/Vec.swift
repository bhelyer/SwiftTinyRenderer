public typealias Real = Float

public struct Vec2i : CustomStringConvertible {
    public var x = 0
    public var y = 0

    public subscript(componentIndex: Int) -> Int {
        get {
            assert(componentIndex == 0 || componentIndex == 1, "Vec2: bad index")
            if componentIndex == 0 {
                return x
            } else if componentIndex == 1 {
                return y
            } else {
                return Int(0)
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
    }

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    public static func +(left: Vec2i, right: Vec2i) -> Vec2i {
        return Vec2i(x: left.x + right.x, y: left.y + right.y)
    }

    public static func -(left: Vec2i, right: Vec2i) -> Vec2i {
        return Vec2i(x: left.x - right.x, y: left.y - right.y)
    }

    public static func *(left: Vec2i, right: Real) -> Vec2i {
        return Vec2i(x: Int(Real(left.x) * right), y: Int(Real(left.y) * right))
    }

    public var description: String {
        return "(\(x), \(y))"
    }
}

public struct Vec2r : CustomStringConvertible {
    public var x = Real(0)
    public var y = Real(0)

    public subscript(componentIndex: Int) -> Real {
        get {
            assert(componentIndex == 0 || componentIndex == 1, "Vec2: bad index")
            if componentIndex == 0 {
                return x
            } else if componentIndex == 1 {
                return y
            } else {
                return Real(0)
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
    }

    public init(x: Real, y: Real) {
        self.x = x
        self.y = y
    }
    
    public static func +(left: Vec2r, right: Vec2r) -> Vec2r {
        return Vec2r(x: left.x + right.x, y: left.y + right.y)
    }

    public static func -(left: Vec2r, right: Vec2r) -> Vec2r {
        return Vec2r(x: left.x - right.x, y: left.y - right.y)
    }

    public static func *(left: Vec2r, right: Real) -> Vec2r {
        return Vec2r(x: left.x * right, y: Real(left.y) * right)
    }

    public var description: String {
        return "(\(x), \(y))"
    }
}

public struct Vec3r : CustomStringConvertible {
    public var x = Real(0)
    public var y = Real(0)
    public var z = Real(0)

    public subscript(componentIndex: Int) -> Real {
        get {
            assert(componentIndex >= 0 && componentIndex <= 2, "Vec3: bad index")
            if componentIndex == 0 {
                return x
            } else if componentIndex == 1 {
                return y
            } else if componentIndex == 2 {
                return z
            } else {
                return Real(0)
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
    }

    public init(x: Real, y: Real, z: Real) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    /// Calculate the cross product of two vectors.
    public static func ^(left: Vec3r, right: Vec3r) -> Vec3r {
        return Vec3r(x: left.y * right.z - left.z * right.y,
                       y: left.z * right.x - left.x * right.z,
                       z: left.x * right.y - left.y * right.x)
    }

    public static func +(left: Vec3r, right: Vec3r) -> Vec3r {
        return Vec3r(x: left.x + right.x, y: left.y + right.y, z: left.z + right.z)
    }

    public static func -(left: Vec3r, right: Vec3r) -> Vec3r {
        return Vec3r(x: left.x - right.x, y: left.y - right.y, z: left.z - right.z)
    }

    public static func *(left: Vec3r, right: Real) -> Vec3r {
        return Vec3r(x: left.x * right, y: left.y * right, z: left.z * right)
    }

    /// Calculate the dot product of two vectors.
    public static func *(left: Vec3r, right: Vec3r) -> Real {
        return left.x * right.x + left.y * right.y + left.z * right.z
    }

    /// Return the length of this vector.
    public var length: Real {
        let xx = x * x
        let yy = y * y
        let zz = z * z
        return (xx + yy + zz).squareRoot()
    }

    /// Transform this vector so its length is `length` (default 1).
    public mutating func normalise(toLength l: Real = 1) {
        self = self * (l / length)
    }

    public var description: String {
        return "(\(x), \(y), \(z))"
    }
}