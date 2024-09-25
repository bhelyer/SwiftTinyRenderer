import Foundation

let white = TGAColour(r: 255, g: 255, b: 255, a: 255)
let red = TGAColour(r: 255, g: 0, b: 0, a: 255)
let green = TGAColour(r: 0, g: 255, b: 0, a: 255)
let width = 800
let height = 800

var tImage = TGAImage(width: 200, height: 200, format: .rgb)
let t0 = [Vec2i(x: 10, y: 70), Vec2i(x: 50, y: 160), Vec2i(x: 70, y: 80)]
let t1 = [Vec2i(x: 180, y: 50), Vec2(x: 150, y: 1), Vec2i(x: 70, y: 180)]
let t2 = [Vec2i(x: 180, y: 150), Vec2i(x: 120, y: 160), Vec2i(x: 130, y: 180)]
triangle(t0[0], t0[1], t0[2], &tImage, red)
triangle(t1[0], t1[1], t1[2], &tImage, white)
triangle(t2[0], t2[1], t2[2], &tImage, green)
tImage.flipVertically() // Move origin to bottom left corner.
if !tImage.write(fileTo: "triangles.tga", vflip: false, rle: true) {
    print("Failed to write image.")
}

if CommandLine.arguments.count != 2 {
    print("usage: tinyrenderer model_file.obj")
    exit(1)
}
let model = Model(fromFile: CommandLine.arguments[1])


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

func line(_ a: Vec2i, _ b: Vec2i, _ image: inout TGAImage, _ colour: TGAColour) {
    line(a.x, a.y, b.x, b.y, &image, colour)
}

@MainActor
func triangle(_ v0: Vec2i, _ v1: Vec2i, _ v2: Vec2i, _ image: inout TGAImage, _ colour: TGAColour) {
    // Create mutable copies of the input parameters.
    var v0 = v0
    var v1 = v1
    var v2 = v2

    // Sort the input paramaters in ascending Y order.
    if v0.y > v1.y { swap(&v0, &v1) }
    if v0.y > v2.y { swap(&v0, &v2) }
    if v1.y > v2.y { swap(&v1, &v2) }

    // Draw the bottom half of the triangle.
    // The height of the triangle.
    let totalHeight = v2.y - v0.y
    for y in v0.y...v1.y {
        // The height of the bottom half.
        let segmentHeight = v1.y - v0.y + 1
        // 0 = bottom of triangle, 1 = top of triangle
        // how far along through the long line we are
        let alpha = Real(y - v0.y) / Real(totalHeight)
        // 0 = bottom of segment, 1 = top of segment
        // how far along through the short line we are
        let beta  = Real(y - v0.y) / Real(segmentHeight)
        // (v2 - v0) * alpha -- scale v0 from v2 by alpha
        // +v0 -- put it back in right coordinate system
        var a = v0 + (v2-v0) * alpha
        // ditto for v0 to v1, scaled by beta.
        var b = v0 + (v1-v0) * beta
        // a is the point along the long line
        // b is the point along the short line
        if a.x > b.x { swap(&a, &b) }
        for j in a.x...b.x {
            image.set(x: j, y: y, to: colour)
        }
    }
    // Do the same for the top half.
    // (Except the beta line goes from v1 to v2.)
    for y in v1.y...v2.y {
        let segmentHeight = v2.y - v1.y + 1
        let alpha = Real(y - v0.y) / Real(totalHeight)
        let beta = Real(y - v1.y) / Real(segmentHeight)
        var a = v0 + (v2-v0) * alpha
        var b = v1 + (v2-v1) * beta
        if a.x > b.x { swap(&a, &b) }
        for j in a.x...b.x {
            image.set(x: j, y: y, to: colour)
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
