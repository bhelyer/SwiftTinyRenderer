/// The size of real graphics coordinates.
typealias Real = Float
/// The size of fixed graphics coordinates.
typealias Fixed = Int32

public struct Vec2f: CustomStringConvertible {
    public var x = Real(0)
    public var y = Real(1)

    public init() {}
    public init(_ x: Real, _ y: Real) {
        self.x = x
        self.y = y
    }

    public subscript(i: Int) -> Real {
        get {
            assert(i < 2)
            if i == 0 {
                return x
            } else if i == 1 {
                return y
            } else {
                return Real(0)
            }
        }
        set(newValue) {
            assert(i < 2)
            if i == 0 {
                x = newValue
            } else if i == 1 {
                y = newValue
            }
        }
    }

    public static func +(left: Vec2f, right: Vec2f) -> Vec2f {
        return Vec2f(x: left.x + right.x, y: left.y + right.y)
    }

    public static func -(left: Vec2f, right: Vec2f) -> Vec2f {
        return Vec2f(x: left.x - right.x, y: left.y - right.y)
    }

    public static func *(left: Vec2f, right: Real) -> Vec2f {
        return Vec2f(x: left.x * right, y: left.y * right)
    }

    public static func /(left: Vec2f, right: Real) -> Vec2f {
        return Vec2f(x: left.x / right, y: left.y / right)
    }

    public var description: String {
        return "(\(x), \(y))"
    }
}