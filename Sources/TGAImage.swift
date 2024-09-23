import Foundation

private struct TGAHeader {
    var idlength = UInt8(0)
    var colormaptype = UInt8(0)
    var datatypecode = UInt8(0)
    var colormaporigin = UInt16(0)
    var colormaplength = UInt16(0)
    var colormapdepth = UInt8(0)
    var xOrigin = UInt16(0)
    var yOrigin = UInt16(0)
    var width = UInt16(0)
    var height = UInt16(0)
    var bitsperpixel = UInt8(0)
    var imagedescriptor = UInt8(0)

    mutating func append(to data: inout Data) {
        // Sadly, Swift can't pack structs natively.
        // It's this, or define the header in C.
        data.append(Data(bytes: &idlength, count: MemoryLayout<UInt8>.stride))
        data.append(Data(bytes: &colormaptype, count: MemoryLayout<UInt8>.stride))
        data.append(Data(bytes: &datatypecode, count: MemoryLayout<UInt8>.stride))
        data.append(Data(bytes: &colormaporigin, count: MemoryLayout<UInt16>.stride))
        data.append(Data(bytes: &colormaplength, count: MemoryLayout<UInt16>.stride))
        data.append(Data(bytes: &colormapdepth, count: MemoryLayout<UInt8>.stride))
        data.append(Data(bytes: &xOrigin, count: MemoryLayout<UInt16>.stride))
        data.append(Data(bytes: &yOrigin, count: MemoryLayout<UInt16>.stride))
        data.append(Data(bytes: &width, count: MemoryLayout<UInt16>.stride))
        data.append(Data(bytes: &height, count: MemoryLayout<UInt16>.stride))
        data.append(Data(bytes: &bitsperpixel, count: MemoryLayout<UInt8>.stride))
        data.append(Data(bytes: &imagedescriptor, count: MemoryLayout<UInt8>.stride))
    }
}

public struct TGAColor {
    public var b = UInt8(0)
    public var g = UInt8(0)
    public var r = UInt8(0)
    public var a = UInt8(0)
    public var bpp = UInt8(4)

    public init() {
    }

    public init(r: UInt8, g: UInt8, b: UInt8, a: UInt8, bpp: UInt8 = 4) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
        self.bpp = bpp
    }
}

public struct TGAImage {
    private var bytes: [UInt8] = []
    public private(set) var width = 0
    public private(set) var height = 0
    private var bpp = UInt8(0)

    public enum Format: UInt8 {
        case grayscale = 1
        case rgb = 3
        case rgba = 4
    }

    public init() {
    }

    public init(width: Int, height: Int, format: Format) {
        self.bytes = [UInt8](repeating: 0, count: width * height * Int(format.rawValue))
        self.width = width
        self.height = height
        self.bpp = format.rawValue
    }

    public func read(fromFile filename: String) -> Bool {
        print("read(fromFile: \(filename))")
        return true
    }

    public func write(fileTo filename: String, vflip: Bool = true, rle: Bool = true) -> Bool {
        let developerAreaRef: [UInt8] = [0, 0, 0, 0]
        let extensionAreaRef: [UInt8] = [0, 0, 0, 0]
        let footer: [UInt8] = [
            UInt8(ascii: "T"), UInt8(ascii: "R"), UInt8(ascii: "U"),
            UInt8(ascii: "E"), UInt8(ascii: "V"), UInt8(ascii: "I"),
            UInt8(ascii: "S"), UInt8(ascii: "I"), UInt8(ascii: "O"),
            UInt8(ascii: "N"), UInt8(ascii: "-"), UInt8(ascii: "X"),
            UInt8(ascii: "F"), UInt8(ascii: "I"), UInt8(ascii: "L"),
            UInt8(ascii: "E"), UInt8(ascii: "."), 0
        ]

        var data = Data()
        var header = TGAHeader()
        header.bitsperpixel = UInt8(bpp << 3)
        header.width = UInt16(width)
        header.height = UInt16(height)
        header.datatypecode = UInt8(bpp == Format.grayscale.rawValue ? (rle ? 11 : 3) : (rle ? 10 : 2))
        header.imagedescriptor = vflip ? 0x00 : 0x20
        header.append(to: &data)

        if !rle {
            data.append(contentsOf: bytes)
        } else {
            if !writeRleData(&data) {
                return false
            }
        }
        data.append(contentsOf: developerAreaRef)
        data.append(contentsOf: extensionAreaRef)
        data.append(contentsOf: footer)
        return FileManager.default.createFile(atPath: filename, contents: data)
    }

    public mutating func flipHorizontally() {
        let half = width >> 1
        for i in 0..<half {
            for j in 0..<height {
                for b in 0..<Int(bpp) {
                    // Expression exploded to prevent compiler from exploding.
                    let firstBaseExp = i + j * width
                    let bppExp = Int(bpp)
                    let firstIdx = firstBaseExp * bppExp + b
                    let secondBaseExp = width - 1 - i + j * width
                    let secondIdx = secondBaseExp * bppExp + b
                    bytes.swapAt(firstIdx, secondIdx)
                }
            }
        }
    }

    public mutating func flipVertically() {
        let half = height >> 1
        for i in 0..<width {
            for j in 0..<half {
                for b in 0..<Int(bpp) {
                    // Expression exploded to prevent compiler from exploding.
                    let firstBaseExp = i + j * width
                    let bppExp = Int(bpp)
                    let firstIdx = firstBaseExp * bppExp + b
                    let secondBaseExp = i + (height - 1 - j) * width
                    let secondIdx = secondBaseExp * bppExp + b
                    bytes.swapAt(firstIdx, secondIdx)
                }
            }
        }
    }

    public func get(x: Int, y: Int) -> TGAColor {
        if bytes.count == 0 || x < 0 || y < 0 || x >= width || y >= width {
            return TGAColor()
        }
        var color = TGAColor(r: 0, g: 0, b: 0, a: 0, bpp: bpp)
        let i = (x + y * width) * Int(bpp)
        if bpp >= 1 { color.b = bytes[i    ] }
        if bpp >= 2 { color.g = bytes[i + 1] }
        if bpp >= 3 { color.r = bytes[i + 2] }
        if bpp >= 4 { color.a = bytes[i + 3] }
        return color
    }

    public mutating func set(x: Int, y: Int, to color: TGAColor) -> Bool {
        if bytes.count == 0 || x < 0 || y < 0 || x >= width || y >= width {
            return false
        }
        let i = (x + y * width) * Int(bpp)
        if bpp >= 1 { bytes[i    ] = color.b }
        if bpp >= 2 { bytes[i + 1] = color.g }
        if bpp >= 3 { bytes[i + 2] = color.r }
        if bpp >= 4 { bytes[i + 3] = color.a }
        return true
    }

    private mutating func loadRleData(_ data: Data) -> Bool {
        return false
    }

    private func writeRleData(_ data: inout Data) -> Bool {
        let maxChunkLength = UInt8(128)
        let npixels = width * height
        var curpix = 0
        while curpix < npixels {
            let chunkstart = curpix * Int(bpp)
            var curbyte = curpix * Int(bpp)
            var runLength = UInt8(1)
            var raw = true
            while curpix + Int(runLength) < npixels && Int(runLength) < maxChunkLength {
                var succEq = true
                var t = 0
                while succEq && t < Int(bpp) {
                    succEq = bytes[curbyte + t] == bytes[curbyte + t + Int(bpp)]
                    t += 1
                }
                curbyte += Int(bpp)
                if runLength == 1 {
                    raw = !succEq
                }
                if raw && succEq {
                    runLength -= 1
                    break
                }
                if !raw && !succEq {
                    break
                }
                runLength += 1
            }
            curpix += Int(runLength)
            var bytesToAdd: [UInt8] = []
            if raw {
                bytesToAdd.append(runLength - 1)
                for i in 0..<Int(runLength)*Int(bpp) {
                    bytesToAdd.append(bytes[chunkstart+i])
                }
            } else {
                bytesToAdd.append(runLength + 127)
                for i in 0..<Int(bpp) {
                    bytesToAdd.append(bytes[chunkstart+i])
                }
            }
            data.append(contentsOf: bytesToAdd)
        }
        return true
    }
}