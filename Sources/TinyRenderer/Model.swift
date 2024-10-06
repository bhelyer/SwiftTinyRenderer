import Foundation

private let vertPrefix = "v "
private let facePrefix = "f "
private let texVertPrefix = "vt  "

/// An exceedingly simple WaveFront OBJ 3D model parser.
public struct Model {
    public struct Face {
        public var vertIndices: [Int]
        public var texVertIndices: [Int]
        
        public init() {
            self.vertIndices = []
            self.texVertIndices = []
        }
        
        public init(vertIndices: [Int]) {
            self.vertIndices = vertIndices
            self.texVertIndices = [] // !
        }
    }
    
    private let verts: [Vec3r]
    private let texVerts: [Vec3r]
    private let faces: [Face]

    public init(fromFile filename: String) {
        var verts: [Vec3r] = []
        var texVerts: [Vec3r] = []
        var faces: [Face] = []

        var modelText: String
        do {
            modelText = try String(contentsOfFile: filename, encoding: .utf8)
        } catch {
            print("Failed to open file \"\(filename)\" for reading.")
            self.verts = []
            self.texVerts = []
            self.faces = []
            return
        }

        let lines = modelText.split { $0.isNewline }
        for line in lines {
            if line.hasPrefix(vertPrefix) {
                verts.append(parseVert(line: line))
            } else if line.hasPrefix(facePrefix) {
                faces.append(parseFace(line: line))
            } else if line.hasPrefix(texVertPrefix) {
                texVerts.append(parseTextureVert(line: line))
            }
        }
        self.verts = verts
        self.texVerts = texVerts
        self.faces = faces
        print("# #v \(verts.count) #tv \(texVerts.count) #f \(faces.count)")
    }

    public var nverts: Int {
        return verts.count
    }
    
    public var nTexVerts: Int {
        return texVerts.count
    }

    public var nfaces: Int {
        return faces.count
    }

    public func vert(_ i: Int) -> Vec3r {
        return verts[i]
    }
    
    public func texVert(_ i: Int) -> Vec3r {
        return texVerts[i]
    }

    public func face(_ i: Int) -> Face {
        return faces[i]
    }
}

private func parseVert(line: Substring) -> Vec3r {
    if line.count <= vertPrefix.count {
        print("Invalid vert line given to parseVert.")
        return Vec3r()
    }
    let startIndex = line.index(line.startIndex, offsetBy: vertPrefix.count)
    let vertsStr = line[startIndex..<line.endIndex]
    let vertStrs = vertsStr.split { $0 == " " }
    let verts = vertStrs.map { Real($0) }
    if verts.count != 3 {
        print("More then 3 coordinates on a vert line.")
        return Vec3r()
    }
    for vert in verts {
        if vert == nil {
            print("Failed to parse a coordinate on a vert line.")
            return Vec3r()
        }
    }
    return Vec3r(verts[0]!, verts[1]!, verts[2]!)
}

private func parseTextureVert(line: Substring) -> Vec3r {
    if line.count <= texVertPrefix.count {
        print("Invalid vert line given to parseTextureVert.")
        return Vec3r()
    }
    let startIndex = line.index(line.startIndex, offsetBy: texVertPrefix.count)
    let vertsStr = line[startIndex..<line.endIndex]
    let vertStrs = vertsStr.split { $0 == " " }
    let verts = vertStrs.map { Real($0) }
    if verts.count != 3 {
        print("More then 3 coordinates on a vert line.")
        return Vec3r()
    }
    for vert in verts {
        if vert == nil {
            print("Failed to parse a coordinate on a vert line.")
            return Vec3r()
        }
    }
    return Vec3r(verts[0]!, verts[1]!, verts[2]!)
}

private func parseFace(line: Substring) -> Model.Face {
    if line.count <= facePrefix.count {
        print("Invalid face line given to parseFace.")
        return Model.Face()
    }
    let startIndex = line.index(line.startIndex, offsetBy: facePrefix.count)
    let faceStr = line[startIndex..<line.endIndex]
    let faceGroups = faceStr.split { $0 == " " }
    if faceGroups.count == 0 {
        return Model.Face()
    }
    var face = Model.Face()
    // Given "f 1/2/3 4/5/6 7/8/9", create an array [1-1, 4-1, 7-1].
    for faceGroup in faceGroups {
        let faceStrs = faceGroup.split { $0 == "/" }
        if faceStrs.count == 0 {
            return Model.Face()
        }
        guard let faceIndex = Int(faceStrs[0]) else {
            return Model.Face()
        }
        // In OBJ files, the first index is 1, not 0.
        face.vertIndices.append(faceIndex - 1)
        if faceStrs.count > 1 {
            if let faceTexIndex = Int(faceStrs[1]) {
                face.texVertIndices.append(faceTexIndex - 1)
            }
        }
    }
    return face
}
