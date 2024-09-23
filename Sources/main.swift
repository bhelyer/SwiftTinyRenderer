let white = TGAColour(r: 255, g: 255, b: 255, a: 255)
let red = TGAColour(r: 255, g: 0, b: 0, a: 255)

var image = TGAImage(width: 100, height: 100, format: .rgb)

/// The floating point type used.
typealias Real = Double

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

    let denom = Real(x1 - x0)
    let ry0 = Real(y0)
    let ry1 = Real(y1)
    for x in x0..<x1 {
        let t = Real(x - x0) / denom
        let y = ry0 * (1.0 - t) + ry1 * t
        if !steep {
            image.set(x: x, y: Int(y), to: colour)
        } else {
            // If transposed, de-transpose it.
            image.set(x: Int(y), y: x, to: colour)
        }
    }
}

for _ in 0...1000000 {
    line(13, 20, 80, 40, &image, white)
    line(20, 13, 40, 80, &image, red)
    line(80, 40, 13, 20, &image, red)
}

image.flipVertically() // Move origin to bottom left corner.
if !image.write(fileTo: "output.tga", vflip: false, rle: true) {
    print("Failed to write image.")
}