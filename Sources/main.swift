let white = TGAColor(r: 255, g: 255, b: 255, a: 255)
let red = TGAColor(r: 255, g: 0, b: 0, a: 255)

var image = TGAImage(width: 100, height: 100, format: .rgb)
_ = image.set(x: 52, y: 41, to: red)
image.flipVertically() // Move origin to bottom left corner.
//image.flipHorizontally()
if !image.write(fileTo: "output.tga", vflip: false, rle: true) {
    print("Failed to write image.")
}