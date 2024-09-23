let white = TGAColour(r: 255, g: 255, b: 255, a: 255)
let red = TGAColour(r: 255, g: 0, b: 0, a: 255)

var image = TGAImage(width: 100, height: 100, format: .rgb)

/// The floating point type used.
typealias Real = Float

func line(_ x0: Int, _ y0: Int, _ x1: Int, _ y1: Int, _ image: inout TGAImage, _ colour: TGAColour) {
    if x0 >= x1 {
        return
    }
    for x in x0..<x1 {
        let t = Real(x - x0) / Real(x1 - x0)
        let y = Real(y0) * (1.0 - t) + Real(y1) * t
        _ = image.set(x: x, y: Int(y), to: colour)
    }
}

line(13, 20, 80, 40, &image, white)
line(20, 13, 40, 80, &image, red)
line(80, 40, 13, 20, &image, red)

image.flipVertically() // Move origin to bottom left corner.
if !image.write(fileTo: "output.tga", vflip: false, rle: true) {
    print("Failed to write image.")
}