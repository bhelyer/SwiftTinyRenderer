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
            drawTriangle(screenCoords, c)
        }
    }

    public mutating func drawTriangle(_ a: Vec2i, _ b: Vec2i, _ colour: TGAColour) {
        // Create mutable copies of arguments, so we can swap them about.
        var x0 = a.x
        var y0 = a.y
        var x1 = b.x
        var y1 = b.y

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

    public mutating func drawTriangle(_ pts: [Vec2i], _ colour: TGAColour) {
        assert(pts.count == 3, "incorrect number of points passed to Renderer::drawTriangle.")
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
}

public enum RendererError : Error {
    case saveFailed
}