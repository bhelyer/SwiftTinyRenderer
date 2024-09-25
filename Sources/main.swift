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
triangle(t0, &tImage, red)
triangle(t1, &tImage, white)
triangle(t2, &tImage, green)
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
func simpleTriangle(_ v0: Vec2i, _ v1: Vec2i, _ v2: Vec2i, _ image: inout TGAImage, _ colour: TGAColour) {
    // Discard degenerate triangles.
    if v0.y == v1.y && v0.y == v2.y { return }

    // Create mutable copies of the input parameters.
    var v0 = v0
    var v1 = v1
    var v2 = v2

    // Sort the input paramaters in ascending Y order.
    if v0.y > v1.y { swap(&v0, &v1) }
    if v0.y > v2.y { swap(&v0, &v2) }
    if v1.y > v2.y { swap(&v1, &v2) }

    // As v2 is the highest point, and v0 is the lowest,
    // this calculates the total height of the triangle.
    let totalHeight = v2.y - v0.y
    // Scan up the triangle, drawing horizontal bands of colour.
    for i in 0..<totalHeight {
        // Most triangles can be split horizontally into two triangles:
        //         * <-- v2
        //        /|
        //       / |
        //      /  |
        //     /---* <-- v1
        //    /  /
        //   / /
        //  */       <-- v0
        // To draw a horizontal band, we need to know both sides of the
        // line. One will always land on the line v0 to v2. But depending
        // on where we are up the triangle, the other point will either
        // be on the line v0 to v1 or v1 to v2.
        // If secondHalf is false, we need the line v0 to v1, if it is
        // true then we need the line v1 to v2.
        let secondHalf = i>v1.y-v0.y || v1.y == v0.y
        // This is the height of the segment that we're in.
        let segmentHeight = Real(secondHalf ? v2.y-v1.y : v1.y-v0.y)
        // The alpha is the how far along v0 to v2 the point on that line is.
        // 0 and the point is v0. 1 and the point is v2. Anything else,
        // somewhere in between.
        let alpha = Real(i) / Real(totalHeight)
        // The beta is the same idea, but for the other line we're interested
        // in. (v0 to v1 or v1 to v2.)
        let beta = Real(i-(secondHalf ? v1.y - v0.y : 0)) / segmentHeight
        // So now, using alpha and beta calculating the points on either
        // side of the horizontal line we want to draw is trivial;
        // we simply scale the line in question against alpha or beta.
        var a =              v0 + (v2-v0)*alpha
        var b = secondHalf ? v1 + (v2-v1)*beta : v0 + (v1-v0)*beta
        // Sort a and b in ascending X order.
        if a.x > b.x { swap(&a, &b) }
        // Finally, draw the line.
        for j in a.x...b.x {
            // Note that due to casting a and b into integer vectors,
            // a.y != v0.y+i.
            image.set(x: j, y: v0.y+i, to: colour)
        }
    }
}

func barycentric(_ pts: [Vec2i], _ p: Vec2i) -> Vec3r {
    let lx = Real(pts[2][0]-pts[0][0])
    let ly = Real(pts[1][0]-pts[0][0])
    let lz = Real(pts[0][0]-p[0])
    let l = Vec3r(x: lx, y: ly, z: lz)

    let rx = Real(pts[2][1]-pts[0][1])
    let ry = Real(pts[1][1]-pts[0][1])
    let rz = Real(pts[0][1]-p[1])
    let r = Vec3r(x: rx, y: ry, z: rz)

    let u = l ^ r

    // `pts` and `p` have integer value coordinates.
    // `abs(u[2]) < 1` means `u[2]` is 0, which means
    // the triangle is degenerate. Return something with negative coords.
    if abs(u.z) < 1 { return Vec3r(x: -1, y: -1, z: -1) }

    let x = 1.0 - (u.x + u.y) / u.z
    let y = u.y / u.z
    let z = u.x / u.z
    return Vec3r(x: x, y: y, z: z)
}

func triangle(_ pts: [Vec2i], _ image: inout TGAImage, _ colour: TGAColour) {
    var bboxmin = Vec2i(x: image.width - 1, y: image.height - 1)
    var bboxmax = Vec2i(x: 0, y: 0)
    let clamp = Vec2i(x: image.width - 1, y: image.height - 1)
    for i in 0..<3 {
        bboxmin.x = max(0, min(bboxmin.x, pts[i].x))
        bboxmin.y = max(0, min(bboxmin.y, pts[i].y))

        bboxmax.x = max(clamp.x, min(bboxmax.x, pts[i].x))
        bboxmax.y = max(clamp.y, min(bboxmax.y, pts[i].y))
    }

    for x in bboxmin.x...bboxmax.y {
        for y in bboxmin.y...bboxmax.y {
            let p = Vec2i(x: x, y: y)
            let bcScreen = barycentric(pts, p)
            if bcScreen.x < 0 || bcScreen.y < 0 || bcScreen.z < 0 {
                continue
            }
            image.set(x: p.x, y: p.y, to: colour)
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
