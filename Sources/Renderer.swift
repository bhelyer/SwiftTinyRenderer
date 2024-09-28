public class Renderer {
    private var image: TGAImage
    private var zbuffer: UnsafeMutableBufferPointer<Real>
    private var screenCoords: [Vec3r]//UnsafeMutableBufferPointer<Vec3r>
    private var worldCoords: [Vec3r]//UnsafeMutableBufferPointer<Vec3r>

    public init(width: Int, height: Int) {
        image = TGAImage(width: width, height: height, format: .rgb)
        zbuffer = UnsafeMutableBufferPointer<Real>.allocate(capacity: width * height)
        zbuffer.initialize(repeating: -Real.greatestFiniteMagnitude)
        screenCoords = [Vec3r](repeating: Vec3r(), count: 3)
        worldCoords = [Vec3r](repeating: Vec3r(), count: 3)//UnsafeMutableBufferPointer<Vec3r>.allocate(capacity: 3)
        //screenCoords.initialize(repeating: Vec2i())
        ///worldCoords = UnsafeMutableBufferPointer<Vec3r>.allocate(capacity: 3)
        //worldCoords.initialize(repeating: Vec3r())
    }

    deinit {
        zbuffer.deallocate()
        //screenCoords.deallocate()
        //worldCoords.deallocate()
    }

    public func saveScreenshot(to filename: String) throws {
        var snapshot = image
        snapshot.flipVertically()
        if !snapshot.write(fileTo: filename, vflip: false, rle: true) {
            throw RendererError.saveFailed
        }
    }

    public func render(model: Model) {
        let lightDir = Vec3r(x: 0, y: 0, z: -1)
        var c = TGAColour(r: 0, g: 0, b: 0, a: 255)
        //var screenCoords = [Vec2i](repeating: Vec2i(), count: 3)
        //var worldCoords = [Vec3r](repeating: Vec3r(), count: 3)
        for i in 0..<model.nfaces {
            //print("\rface: \(i) of \(model.nfaces)")
            let face = model.face(i)
            let halfWidth = Real(image.width) / 2.0
            let halfHeight = Real(image.height) / 2.0
            for j in 0..<3 {
                let v0 = model.vert(face[j])
                let x0 = Int((v0.x + 1.0) * halfWidth + 0.5)
                let y0 = Int((v0.y + 1.0) * halfHeight + 0.5)
                screenCoords[j] = Vec3r(x: Real(x0), y: Real(y0), z: v0.z)
                worldCoords[j]  = v0
            }
            // Get a unit vector perpendicular to the triangle.
            var n = (worldCoords[2]-worldCoords[0])^(worldCoords[1]-worldCoords[0])
            n.normalise()
            let intensity = n * lightDir
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

    // This, absent anything else, is a lot slower than the other function.
    public func drawBarycentricTriangle(_ pts: [Vec3r], _ colour: TGAColour) {
        var bboxmin = Vec2r(x: Real.greatestFiniteMagnitude, y: Real.greatestFiniteMagnitude)
        var bboxmax = Vec2r(x: -Real.greatestFiniteMagnitude, y: -Real.greatestFiniteMagnitude)
        let clamp = Vec2r(x: Real(image.width - 1), y: Real(image.height - 1))
        for i in 0..<3 {
            bboxmin.x = max(0, min(bboxmin.x, pts[i].x))
            bboxmin.y = max(0, min(bboxmin.y, pts[i].y))

            bboxmax.x = max(clamp.x, min(bboxmax.x, pts[i].x))
            bboxmax.y = max(clamp.y, min(bboxmax.y, pts[i].y))
        }

        var p = Vec3r()
        p.x = bboxmin.x
        while p.x <= bboxmax.x {
            //for y in bboxmin.y...bboxmax.y {
            p.y = bboxmin.y
            while p.y <= bboxmax.y {
                let bcScreen = barycentric(pts, p)
                if bcScreen.x < 0 || bcScreen.y < 0 || bcScreen.z < 0 {
                    p.y += 1.0
                    continue
                }
                p.z = 0
                for i in 0..<3 { p.z += Real(pts[i][2]) * bcScreen[i] }
                let index = Int(p.y) * image.width + Int(p.x)
                if zbuffer[index] < p.z {
                    zbuffer[index] = p.z
                    image.set(x: Int(p.x), y: Int(p.y), to: colour)
                }
                p.y += 1.0
            }
            p.x += 1.0
        }
    }

    public func drawTriangle(_ pts: [Vec2i], _ colour: TGAColour) {
        // Create mutable copies of the input parameters.
        var v0 = pts[0]
        var v1 = pts[1]
        var v2 = pts[2]
    
        // Discard degenerate triangles.
        if v0.y == v1.y && v0.y == v2.y { return }

        // Sort the input paramaters in ascending Y order.
        if v0.y > v1.y { swap(&v0, &v1) }
        if v0.y > v2.y { swap(&v0, &v2) }
        if v1.y > v2.y { swap(&v1, &v2) }

        // As v2 is the highest point, and v0 is the lowest,
        // this calculates the total height of the triangle.
        let totalHeight = v2.y - v0.y
        colour.bgra.withUnsafeBufferPointer {
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
                // Note that due to casting a and b into integer vectors,
                // a.y != v0.y+i.
                image.setHorizUnsafe(x0: a.x, x1: b.x, y: v0.y + i, to: $0)
            }
        }
    }

}

public enum RendererError : Error {
    case saveFailed
}