let white = TGAColour(r: 255, g: 255, b: 255, a: 255)
let red = TGAColour(r: 255, g: 0, b: 0, a: 255)

var image = TGAImage(width: 100, height: 100, format: .rgb)

/// The floating point type used.


func line(_ x0: Int, _ y0: Int, _ x1: Int, _ y1: Int, _ image: inout TGAImage, _ colour: TGAColour) {
    // Create mutable copies of arguments, so we can swap them about.
    var x0 = x0
    var y0 = y0
    var x1 = x1
    var y1 = y1

    // If the line is steep, transpose it.
    let steep = abs(x0 - x1) < abs(y0 - y1)
    if steep {
        swap(&x0, &y0)
        swap(&x1, &y1)
    }

    // Ensure that it's left-to-right.
    if x0 > x1 {
        swap(&x0, &x1)
        swap(&y0, &y1)
    }

    let dx = x1 - x0
    let dy = y1 - y0
    let derror = abs(dy) * 2
    var error = 0
    var y = y0
    for x in x0..<x1 {
        if !steep {
            image.set(x: x, y: y, to: colour)
        } else {
            // De-transpose it.
            image.set(x: y, y: x, to: colour)
        }
        error += derror
        if error > dx {
            y += y1 > y0 ? 1 : -1
            error -= dx * 2
        }
    }
}

line(13, 20, 80, 40, &image, white)
line(20, 13, 40, 80, &image, red)
line(80, 40, 13, 20, &image, red)

image.flipVertically() // Move origin to bottom left corner.
if !image.write(fileTo: "output.tga", vflip: false, rle: true) {
    print("Failed to write image.")
}

let v = Vec2r(x: 1.0, y: 3.0)
print("hello \(v + Vec2r(x: 0.5, y: -0.3))")
let v2 = Vec2i(x: 3, y: 4)
print("hello \(v2 * 0.5)")

let v3 = Vec3r(x: 1.0, y: 2.0, z: 3.0)
var v4 = Vec3r(x: 2.0, y: 3.0, z: 4.0)
print("v4.len = \(v4.length) \(v4)")
v4.normalise(toLength: 2.0)
print("v4.len = \(v4.length) \(v4)")
var v5 = Vec3i(x: 2, y: 3, z: 4)
print("v5.len = \(v5.length) \(v5)")
v5.normalise(toLength: 2.0)
print("v5.len = \(v5.length) \(v5)")