public class Renderer {
    private var image: TGAImage
    private var texture: TGAImage?
    private var zbuffer: UnsafeMutableBufferPointer<Real>
    private var screenCoords: [Vec3r]
    private var worldCoords: [Vec3r]
    private var texCoords: [Vec2r]
    private let depth: Fixed
    private var camera: Vec3r = Vec3r(0, 0, 3)

    public init(width: Fixed, height: Fixed, depth: Fixed) {
        image = TGAImage(width: width, height: height, format: .rgb)
        zbuffer = UnsafeMutableBufferPointer<Real>.allocate(capacity: Int(width * height))
        zbuffer.initialize(repeating: -Real.greatestFiniteMagnitude)
        screenCoords = [Vec3r](repeating: Vec3r(), count: 3)
        worldCoords = [Vec3r](repeating: Vec3r(), count: 3)
        texCoords = [Vec2r](repeating: Vec2r(), count: 3)
        self.depth = depth
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
        var projection = Matrix.identity(dimensions: 4)
        let viewPort = viewport(image.width / 8, image.height / 8, image.width * 3 / 4, image.height * 3 / 4)
        projection[3, 2] = Real(-1) / camera.z
        
        let lightDir = Vec3r(0, 0, -1)
        var c = TGAColour(r: 0, g: 0, b: 0, a: 255)
        for i in 0..<model.nfaces {
            let face = model.face(i)
            for j in 0..<3 {
                let v0 = model.vert(face.vertIndices[j])
                screenCoords[j] = m2v(viewPort * projection * v2m(v0))
                worldCoords[j]  = v0
                
                if let texture {
                    let tv0 = model.texVert(face.texVertIndices[j])
                    let tx0 = Real(texture.width) * tv0.x
                    // Our Y goes from bottom to top, textures are reversed.
                    // 1.0 - tv0.y inverts 1 to 0 and 0 to 1.
                    let ty0 = Real(texture.height) * (Real(1.0) - tv0.y)
                    texCoords[j] = Vec2r(tx0, ty0)
                }
            }
            // Get a unit vector perpendicular to the triangle.
            var n = cross((worldCoords[2] - worldCoords[0]), (worldCoords[1] - worldCoords[0]))
            n.normalise()
            let intensity = dot(n, lightDir)
            if intensity < 0.0 { continue }

            if texture != nil {
                drawTexturedBarycentricTriangle(screenCoords, texCoords, intensity)
            } else {
                let lightVal = UInt8(255 * intensity)
                c.r = lightVal
                c.g = lightVal
                c.b = lightVal
                drawBarycentricTriangle(screenCoords, c)
            }
            
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
    
    public func drawTexturedBarycentricTriangle(_ pts: [Vec3r], _ texs: [Vec2r], _ intensity: Real) {
        guard let texture = texture else {
            print("Called drawTexturedBarycentricTriangle with nil texture.")
            return
        }
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
                    
                    let tx = texs[0][0] * bcScreen.x + texs[1][0] * bcScreen.y + texs[2][0] * bcScreen.z
                    let ty = texs[0][1] * bcScreen.x + texs[1][1] * bcScreen.y + texs[2][1] * bcScreen.z
                    var c = texture.get(x: Fixed(tx), y: Fixed(ty))
                    c.r = UInt8(Real(c.r) * intensity)
                    c.g = UInt8(Real(c.g) * intensity)
                    c.b = UInt8(Real(c.b) * intensity)
                    
                    image.set(x: Fixed(p.x), y: Fixed(p.y), to: c)
                }
                p.y += 1.0
            }
            p.x += 1.0
        }
    }
    
    func viewport(_ x: Fixed, _ y: Fixed, _ w: Fixed, _ h: Fixed) -> Matrix {
        var m = Matrix.identity(dimensions: 4)
        m[0, 3] = Real(x) + Real(w) / Real(2)
        m[1, 3] = Real(y) + Real(h) / Real(2)
        m[2, 3] = Real(depth) / Real(2)
        
        m[0, 0] = Real(w) / Real(2)
        m[1, 1] = Real(h) / Real(2)
        m[2, 2] = Real(depth) / Real(2)
        return m
    }
}

func m2v(_ m: Matrix) -> Vec3r {
    return Vec3r(m[0, 0] / m[3, 0], m[1, 0] / m[3, 0], m[2, 0] / m[3, 0])
}

func v2m(_ v: Vec3r) -> Matrix {
    var m = Matrix(4, 1)
    m[0, 0] = v.x
    m[1, 0] = v.y
    m[2, 0] = v.z
    m[3, 0] = 1
    return m
}

public enum RendererError : Error {
    case saveFailed
    case loadFailed
}
