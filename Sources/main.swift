let white = TGAColour(r: 255, g: 255, b: 255, a: 255)
let red = TGAColour(r: 255, g: 0, b: 0, a: 255)

var image = TGAImage(width: 100, height: 100, format: .rgb)

func line(_ x0: Int, _ y0: Int, _ x1: Int, _ y1: Int, _ image: inout TGAImage, _ colour: TGAColour) {
    var t = 0.0
    while t < 1.0 {
        let x = x0 + Int(Double(x1 - x0) * t)
        let y = y0 + Int(Double(y1 - y0) * t)
        _ = image.set(x: x, y: y, to: colour)
        t += 0.1
    }
}

line(13, 20, 80, 40, &image, white)

image.flipVertically() // Move origin to bottom left corner.
if !image.write(fileTo: "output.tga", vflip: false, rle: true) {
    print("Failed to write image.")
}