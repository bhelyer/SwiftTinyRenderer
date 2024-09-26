public typealias Real = Double

public protocol Number {
    init(_ value: Int)
    init(_ value: Real)
    init(_ value: Self)
    static func +(lhs: Self, rhs: Self) -> Self
    static func -(lhs: Self, rhs: Self) -> Self
    static func *(lhs: Self, rhs: Self) -> Self
    static func /(lhs: Self, rhs: Self) -> Self
    static func *(lhs: Self, rhs: Real) -> Self
    static func *(lhs: Real, rhs: Self) -> Self
    func squareRoot() -> Real
}

extension Real : Number {
}

extension Int : Number {
    @inlinable public static func *(lhs: Int, rhs: Real) -> Int {
        return Int(Real(lhs) * rhs)
    }

    @inlinable public static func *(lhs: Real, rhs: Int) -> Int {
        return Int(lhs * Real(rhs))
    }

    @inlinable public func squareRoot() -> Real {
        return Real(self).squareRoot()
    }
}

public struct Vec2<T : Number> : CustomStringConvertible {
    @usableFromInline var rawX = T(0)
    @usableFromInline var rawY = T(0)

    @inlinable public var x: T {
        get { return rawX }
        set(newValue) { rawX = newValue }
    }

    @inlinable public var y: T {
        get { return rawY }
        set(newValue) { rawY = newValue }
    }

    @inlinable public var u: T {
        get { return rawX }
        set(newValue) { rawX = newValue }
    }

    @inlinable public var v: T {
        get { return rawY }
        set(newValue) { rawY = newValue }
    }

    @inlinable public subscript(componentIndex: Int) -> T {
        get {
            assert(componentIndex == 0 || componentIndex == 1, "Vec2: bad index")
            if componentIndex == 0 {
                return rawX
            } else if componentIndex == 1 {
                return rawY
            } else {
                return T(0)
            }
        }
        set(newValue) {
            assert(componentIndex == 0 || componentIndex == 1, "Vec2: bad index")
            if componentIndex == 0 {
                rawX = newValue
            } else if componentIndex == 1 {
                rawY = newValue
            }
        }
    }

    @inlinable public init() {
    }

    @inlinable public init(x: T, y: T) {
        self.rawX = x
        self.rawY = y
    }
    
    @inlinable public static func +(left: Vec2<T>, right: Vec2<T>) -> Vec2<T> {
        return Vec2<T>(x: left.x + right.x, y: left.y + right.y)
    }

    @inlinable public static func -(left: Vec2<T>, right: Vec2<T>) -> Vec2<T> {
        return Vec2<T>(x: left.x - right.x, y: left.y - right.y)
    }

    @inlinable public static func *(left: Vec2<T>, right: Real) -> Vec2<T> {
        return Vec2<T>(x: left.x * right, y: left.y * right)
    }

    @inlinable public var description: String {
        return "(\(rawX), \(rawY))"
    }
}

public struct Vec3<T : Number> : CustomStringConvertible {
    @usableFromInline var rawX = T(0)
    @usableFromInline var rawY = T(0)
    @usableFromInline var rawZ = T(0)

    @inlinable public var x: T {
        get { return rawX }
        set(newValue) { rawX = newValue }
    }

    @inlinable public var y: T {
        get { return rawY }
        set(newValue) { rawY = newValue }
    }

    @inlinable public var z: T {
        get { return rawZ }
        set(newValue) { rawZ = newValue }
    }

    @inlinable public var ivert: T {
        get { return rawX }
        set(newValue) { rawX = newValue }
    }

    @inlinable public var iuv: T {
        get { return rawY }
        set(newValue) { rawY = newValue }
    }

    @inlinable public var inorm: T {
        get { return rawZ }
        set(newValue) { rawZ = newValue }
    }

    @inlinable public subscript(componentIndex: Int) -> T {
        get {
            assert(componentIndex >= 0 && componentIndex <= 2, "Vec3: bad index")
            if componentIndex == 0 {
                return rawX
            } else if componentIndex == 1 {
                return rawY
            } else if componentIndex == 2 {
                return rawZ
            } else {
                return T(0)
            }
        }
        set(newValue) {
            assert(componentIndex >= 0 && componentIndex <= 2, "Vec3: bad index")
            if componentIndex == 0 {
                rawX = newValue
            } else if componentIndex == 1 {
                rawY = newValue
            } else if componentIndex == 2 {
                rawZ = newValue
            }
        }
    }

    @inlinable public init() {
    }

    @inlinable public init(x: T, y: T, z: T) {
        rawX = x
        rawY = y
        rawZ = z
    }
    
    /// Calculate the cross product of two vectors.
    @inlinable public static func ^(left: Vec3<T>, right: Vec3<T>) -> Vec3<T> {
        return Vec3<T>(x: left.y * right.z - left.z * right.y,
                       y: left.z * right.x - left.x * right.z,
                       z: left.x * right.y - left.y * right.x)
    }

    @inlinable public static func +(left: Vec3<T>, right: Vec3<T>) -> Vec3<T> {
        return Vec3<T>(x: left.x + right.x, y: left.y + right.y, z: left.z + right.z)
    }

    @inlinable public static func -(left: Vec3<T>, right: Vec3<T>) -> Vec3<T> {
        return Vec3<T>(x: left.x - right.x, y: left.y - right.y, z: left.z - right.z)
    }

    @inlinable public static func *(left: Vec3<T>, right: Real) -> Vec3<T> {
        return Vec3<T>(x: left.x * right, y: left.y * right, z: left.z * right)
    }

    /// Calculate the dot product of two vectors.
    @inlinable public static func *(left: Vec3<T>, right: Vec3<T>) -> T {
        return left.x * right.x + left.y * right.y + left.z * right.z
    }

    /// Return the length of this vector.
    @inlinable public var length: Real {
        let xx = rawX * rawX
        let yy = rawY * rawY
        let zz = rawZ * rawZ
        return (xx + yy + zz).squareRoot()
    }

    /// Transform this vector so its length is `length` (default 1).
    @inlinable public mutating func normalise(toLength l: Real = 1) {
        self = self * (l / length)
    }

    @inlinable public var description: String {
        return "(\(rawX), \(rawY), \(rawZ))"
    }
}

public typealias Vec2r = Vec2<Real>
public typealias Vec2i = Vec2<Int>
public typealias Vec3r = Vec3<Real>
public typealias Vec3i = Vec3<Int>