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
    public static func *(lhs: Int, rhs: Real) -> Int {
        return Int(Real(lhs) * rhs)
    }

    public static func *(lhs: Real, rhs: Int) -> Int {
        return Int(lhs * Real(rhs))
    }

    public func squareRoot() -> Real {
        return Real(self).squareRoot()
    }
}

public struct Vec2<T : Number> : CustomStringConvertible {
    private var rawX = T(0)
    private var rawY = T(0)

    public var x: T {
        get { return rawX }
        set(newValue) { rawX = newValue }
    }

    public var y: T {
        get { return rawY }
        set(newValue) { rawY = newValue }
    }

    public var u: T {
        get { return rawX }
        set(newValue) { rawX = newValue }
    }

    public var v: T {
        get { return rawY }
        set(newValue) { rawY = newValue }
    }

    public init() {
    }

    public init(x: T, y: T) {
        self.rawX = x
        self.rawY = y
    }
    
    public static func +(left: Vec2<T>, right: Vec2<T>) -> Vec2<T> {
        return Vec2<T>(x: left.x + right.x, y: left.y + right.y)
    }

    public static func -(left: Vec2<T>, right: Vec2<T>) -> Vec2<T> {
        return Vec2<T>(x: left.x - right.x, y: left.y - right.y)
    }

    public static func *(left: Vec2<T>, right: Real) -> Vec2<T> {
        return Vec2<T>(x: left.x * right, y: left.y * right)
    }

    public var description: String {
        return "(\(rawX), \(rawY))"
    }
}

public struct Vec3<T : Number> : CustomStringConvertible {
    private var rawX = T(0)
    private var rawY = T(0)
    private var rawZ = T(0)

    public var x: T {
        get { return rawX }
        set(newValue) { rawX = newValue }
    }

    public var y: T {
        get { return rawY }
        set(newValue) { rawY = newValue }
    }

    public var z: T {
        get { return rawZ }
        set(newValue) { rawZ = newValue }
    }

    public var ivert: T {
        get { return rawX }
        set(newValue) { rawX = newValue }
    }

    public var iuv: T {
        get { return rawY }
        set(newValue) { rawY = newValue }
    }

    public var inorm: T {
        get { return rawZ }
        set(newValue) { rawZ = newValue }
    }

    public init() {
    }

    public init(x: T, y: T, z: T) {
        rawX = x
        rawY = y
        rawZ = z
    }
    
    /// Calculate the cross product of two vectors.
    public static func ^(left: Vec3<T>, right: Vec3<T>) -> Vec3<T> {
        return Vec3<T>(x: left.y * right.z - left.z * right.y,
                       y: left.z * right.x - left.x * right.z,
                       z: left.x * right.y - left.y * right.x)
    }

    public static func +(left: Vec3<T>, right: Vec3<T>) -> Vec3<T> {
        return Vec3<T>(x: left.x + right.x, y: left.y + right.y, z: left.z + right.z)
    }

    public static func -(left: Vec3<T>, right: Vec3<T>) -> Vec3<T> {
        return Vec3<T>(x: left.x - right.x, y: left.y - right.y, z: left.z - right.z)
    }

    public static func *(left: Vec3<T>, right: Real) -> Vec3<T> {
        return Vec3<T>(x: left.x * right, y: left.y * right, z: left.z * right)
    }

    /// Calculate the dot product of two vectors.
    public static func *(left: Vec3<T>, right: Vec3<T>) -> T {
        return left.x * right.x + left.y * right.y + left.z * right.z
    }

    /// Return the length of this vector.
    public var length: Real {
        let xx = rawX * rawX
        let yy = rawY * rawY
        let zz = rawZ * rawZ
        return (xx + yy + zz).squareRoot()
    }

    /// Transform this vector so its length is `length` (default 1).
    public mutating func normalise(toLength l: Real = 1) {
        print("l=\(l) length=\(length) scale = \(l / length)")
        self = self * (l / length)
        /*
        let scale = l / 
        rawX = rawX * scale
        rawY = rawY * scale
        rawZ = rawZ * scale
        */
    }

    public var description: String {
        return "(\(rawX), \(rawY), \(rawZ))"
    }
}

typealias Vec2r = Vec2<Real>
typealias Vec2i = Vec2<Int>
typealias Vec3r = Vec3<Real>
typealias Vec3i = Vec3<Int>