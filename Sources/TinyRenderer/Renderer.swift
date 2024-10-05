public class Renderer {
    private var image: TGAImage
    private var texture: TGAImage?
    private var zbuffer: UnsafeMutableBufferPointer<Real>
    private var screenCoords: [Vec3r]
    private var worldCoords: [Vec3r]

    public init(width: Fixed, height: Fixed) {
        image = TGAImage(width: width, height: height, format: .rgb)
        zbuffer = UnsafeMutableBufferPointer<Real>.allocate(capacity: Int(width * height))
        zbuffer.initialize(repeating: -Real.greatestFiniteMagnitude)
        screenCoords = [Vec3r](repeating: Vec3r(), count: 3)
        worldCoords = [Vec3r](repeating: Vec3r(), count: 3)
    }

    deinit {
        zbuffer.deallocate()
    }

    public func saveScreenshot(to filename: String) throws {
        var snapshot = image
        snapshot.flipVertically()
        if !snapshot.write(fileTo: filename, vflip: false, rle: true) {
            throw RendererError.saveFailed
        }
    }
    
    public func loadTexture(from filename: String) throws {
        texture = TGAImage()
        if !texture!.read(fromFile: filename) {
            throw RendererError.loadFailed
        }
    }

    public func render(model: Model) {
        let lightDir = Vec3r(0, 0, -1)
        var c = TGAColour(r: 0, g: 0, b: 0, a: 255)
        for i in 0..<model.nfaces {
            let face = model.face(i)
            let halfWidth = Real(image.width) / 2.0
            let halfHeight = Real(image.height) / 2.0
            for j in 0..<3 {
                let v0 = model.vert(face.vertIndices[j])
                let x0 = Int((v0.x + 1.0) * halfWidth + 0.5)
                let y0 = Int((v0.y + 1.0) * halfHeight + 0.5)
                screenCoords[j] = Vec3r(Real(x0), Real(y0), v0.z)
                worldCoords[j]  = v0
            }
            // Get a unit vector perpendicular to the triangle.
            var n = cross((worldCoords[2] - worldCoords[0]), (worldCoords[1] - worldCoords[0]))
            n.normalise()
            let intensity = dot(n, lightDir)
            if intensity < 0.0 { continue }

            let lightVal = UInt8(255 * intensity)
            c.r = lightVal
            c.g = lightVal
            c.b = lightVal
            drawBarycentricTriangle(screenCoords, c)
        }
    }

    public func drawLine(_ a: Vec2i, _ b: Vec2i, _ colour: TGAColour) {
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
        var error = Fixed(0)
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

    public func drawBarycentricTriangle(_ pts: [Vec3r], _ colour: TGAColour) {
        var bboxmin = Vec2r(Real.greatestFiniteMagnitude, Real.greatestFiniteMagnitude)
        var bboxmax = Vec2r(-Real.greatestFiniteMagnitude, -Real.greatestFiniteMagnitude)
        let clamp = Vec2r(Real(image.width - 1), Real(image.height - 1))
        for i in 0..<3 {
            bboxmin.x = max(0, min(bboxmin.x, pts[i].x))
            bboxmax.x = min(clamp.x, max(bboxmax.x, pts[i].x))
            bboxmin.y = max(0, min(bboxmin.y, pts[i].y))
            bboxmax.y = min(clamp.y, max(bboxmax.y, pts[i].y))
        }

        var p = Vec3r()
        p.x = bboxmin.x
        while p.x <= bboxmax.x {
            //for y in bboxmin.y...bboxmax.y {
            p.y = bboxmin.y
            while p.y <= bboxmax.y {
                let bcScreen = barycentric(pts[0], pts[1], pts[2], p)
                if bcScreen.x < 0 || bcScreen.y < 0 || bcScreen.z < 0 {
                    p.y += 1.0
                    continue
                }
                p.z = 0
                for i in 0..<3 { p.z += Real(pts[i][2]) * bcScreen[i] }
                let index = Fixed(p.y) * image.width + Fixed(p.x)
                if zbuffer[Int(index)] < p.z {
                    zbuffer[Int(index)] = p.z
                    image.set(x: Fixed(p.x), y: Fixed(p.y), to: colour)
                }
                p.y += 1.0
            }
            p.x += 1.0
        }
    }
}

public enum RendererError : Error {
    case saveFailed
    case loadFailed
}
