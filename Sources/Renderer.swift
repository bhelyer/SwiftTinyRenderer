public struct Renderer {
    private var image: TGAImage

    public init(width: Int, height: Int) {
        image = TGAImage(width: width, height: height, format: .rgb)
    }

    public func saveScreenshot(to filename: String) throws {
        var snapshot = image
        snapshot.flipVertically()
        if !snapshot.write(fileTo: "output.tga", vflip: false, rle: true) {
            throw RendererError.saveFailed
        }
    }

    public mutating func render(model: Model) {
        let lightDir = Vec3r(x: 0, y: 0, z: -1)
        var screenCoords = [Vec2i](repeating: Vec2i(), count: 3)
        var worldCoords = [Vec3r](repeating: Vec3r(), count: 3)
        for i in 0..<model.nfaces {
            print("\rface: \(i) of \(model.nfaces)")
            let face = model.face(i)
            let halfWidth = Real(image.width) / 2.0
            let halfHeight = Real(image.height) / 2.0
            for j in 0..<3 {
                let v0 = model.vert(face[j])
                let x0 = Int((v0.x + 1.0) * halfWidth)
                let y0 = Int((v0.y + 1.0) * halfHeight)
                screenCoords[j] = Vec2i(x: x0, y: y0)
                worldCoords[j]  = v0
            }
            // Get a unit vector perpendicular to the triangle.
            var n = (worldCoords[2]-worldCoords[0])^(worldCoords[1]-worldCoords[0])
            n.normalise()
            let intensity = n * lightDir
            if intensity < 0.0 { continue }

            let r = UInt8(255 * intensity)
            let g = UInt8(255 * intensity)
            let b = UInt8(255 * intensity)
            let c = TGAColour(r: r, g: g, b: b, a:255)
            triangle(screenCoords, &image, c)
        }
    }
}

public enum RendererError : Error {
    case saveFailed
}

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

