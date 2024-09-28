import Foundation

private let vertPrefix = "v "
private let facePrefix = "f "

/// An exceedingly simple WaveFront OBJ 3D model parser.
public struct Model {
    private let verts: [Vec3r]
    private let faces: [[Int]]

    public init(fromFile filename: String) {
        var verts: [Vec3r] = []
        var faces: [[Int]] = []

        var modelText: String
        do {
            modelText = try String(contentsOfFile: filename, encoding: .utf8)
        } catch {
            print("Failed to open file \"\(filename)\" for reading.")
            self.verts = []
            self.faces = []
            return
        }

        let lines = modelText.split { $0.isNewline }
        for line in lines {
            if line.hasPrefix(vertPrefix) {
                verts.append(parseVert(line: line))
            } else if line.hasPrefix(facePrefix) {
                faces.append(parseFace(line: line))
            }
        }
        self.verts = verts
        self.faces = faces
        print("# #v \(verts.count) #f \(faces.count)")
    }

    public var nverts: Int {
        return verts.count
    }

    public var nfaces: Int {
        return faces.count
    }

    public func vert(_ i: Int) -> Vec3r {
        return verts[i]
    }

    public func face(_ i: Int) -> [Int] {
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
    return Vec3r(x: verts[0]!, y: verts[1]!, z: verts[2]!)
}

private func parseFace(line: Substring) -> [Int] {
    if line.count <= facePrefix.count {
        print("Invalid face line given to parseFace.")
        return []
    }
    let startIndex = line.index(line.startIndex, offsetBy: facePrefix.count)
    let faceStr = line[startIndex..<line.endIndex]
    let faceGroups = faceStr.split { $0 == " " }
    if faceGroups.count == 0 {
        return []
    }
    var faces: [Int] = []
    // Given "f 1/2/3 4/5/6 7/8/9", create an array [1-1, 4-1, 7-1].
    for faceGroup in faceGroups {
        let faceStrs = faceGroup.split { $0 == "/" }
        if faceStrs.count == 0 {
            return []
        }
        guard let faceIndex = Int(faceStrs[0]) else {
            return []
        }
        // In OBJ files, the first index is 1, not 0.
        faces.append(faceIndex - 1)
    }
    return faces
}