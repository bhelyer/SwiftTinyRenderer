import Foundation

if CommandLine.arguments.count != 2 {
    print("usage: tinyrenderer model_file.obj")
    exit(1)
}
let model = Model(fromFile: CommandLine.arguments[1])

let white = TGAColour(r: 255, g: 255, b: 255, a: 255)
let red = TGAColour(r: 255, g: 0, b: 0, a: 255)
let width = 800
let height = 800

var image = TGAImage(width: width, height: height, format: .rgb)

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

for i in 0..<model.nfaces {
    let face = model.face(i)
    let halfWidth = Real(width) / 2.0
    let halfHeight = Real(height) / 2.0
    for j in 0..<3 {
        let v0 = model.vert(face[j])
        let v1 = model.vert(face[(j+1)%3])
        let x0 = Int((v0.x + 1.0) * halfWidth)
        let y0 = Int((v0.y + 1.0) * halfHeight)
        let x1 = Int((v1.x + 1.0) * halfWidth)
        let y1 = Int((v1.y + 1.0) * halfHeight)
        line(x0, y0, x1, y1, &image, white)
    }
}

image.flipVertically() // Move origin to bottom left corner.
if !image.write(fileTo: "output.tga", vflip: false, rle: true) {
    print("Failed to write image.")
}