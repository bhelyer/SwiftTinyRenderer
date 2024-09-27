import Foundation

private struct TGAHeader {
    var idlength = UInt8(0)
    var colourmaptype = UInt8(0)
    var datatypecode = UInt8(0)
    var colourmaporigin = UInt16(0)
    var colourmaplength = UInt16(0)
    var colourmapdepth = UInt8(0)
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
        data.append(Data(bytes: &colourmaptype, count: MemoryLayout<UInt8>.stride))
        data.append(Data(bytes: &datatypecode, count: MemoryLayout<UInt8>.stride))
        data.append(Data(bytes: &colourmaporigin, count: MemoryLayout<UInt16>.stride))
        data.append(Data(bytes: &colourmaplength, count: MemoryLayout<UInt16>.stride))
        data.append(Data(bytes: &colourmapdepth, count: MemoryLayout<UInt8>.stride))
        data.append(Data(bytes: &xOrigin, count: MemoryLayout<UInt16>.stride))
        data.append(Data(bytes: &yOrigin, count: MemoryLayout<UInt16>.stride))
        data.append(Data(bytes: &width, count: MemoryLayout<UInt16>.stride))
        data.append(Data(bytes: &height, count: MemoryLayout<UInt16>.stride))
        data.append(Data(bytes: &bitsperpixel, count: MemoryLayout<UInt8>.stride))
        data.append(Data(bytes: &imagedescriptor, count: MemoryLayout<UInt8>.stride))
    }

    mutating func read(from data: Data) -> Int {
        var bytesRead = 0
        withUnsafeMutablePointer(to: &idlength) {
            let buffer = UnsafeMutableBufferPointer(start: $0, count: 1)
            bytesRead += data.copyBytes(to: buffer, from: bytesRead..<bytesRead+MemoryLayout<UInt8>.stride)
        }
        withUnsafeMutablePointer(to: &colourmaptype) {
            let buffer = UnsafeMutableBufferPointer(start: $0, count: 1)
            bytesRead += data.copyBytes(to: buffer, from: bytesRead..<bytesRead+MemoryLayout<UInt8>.stride)
        }
        withUnsafeMutablePointer(to: &datatypecode) {
            let buffer = UnsafeMutableBufferPointer(start: $0, count: 1)
            bytesRead += data.copyBytes(to: buffer, from: bytesRead..<bytesRead+MemoryLayout<UInt8>.stride)
        }
        withUnsafeMutablePointer(to: &colourmaporigin) {
            let buffer = UnsafeMutableBufferPointer(start: $0, count: 1)
            bytesRead += data.copyBytes(to: buffer, from: bytesRead..<bytesRead+MemoryLayout<UInt16>.stride)
        }
        withUnsafeMutablePointer(to: &colourmaplength) {
            let buffer = UnsafeMutableBufferPointer(start: $0, count: 1)
            bytesRead += data.copyBytes(to: buffer, from: bytesRead..<bytesRead+MemoryLayout<UInt16>.stride)
        }
        withUnsafeMutablePointer(to: &colourmapdepth) {
            let buffer = UnsafeMutableBufferPointer(start: $0, count: 1)
            bytesRead += data.copyBytes(to: buffer, from: bytesRead..<bytesRead+MemoryLayout<UInt8>.stride)
        }
        withUnsafeMutablePointer(to: &xOrigin) {
            let buffer = UnsafeMutableBufferPointer(start: $0, count: 1)
            bytesRead += data.copyBytes(to: buffer, from: bytesRead..<bytesRead+MemoryLayout<UInt16>.stride)
        }
        withUnsafeMutablePointer(to: &yOrigin) {
            let buffer = UnsafeMutableBufferPointer(start: $0, count: 1)
            bytesRead += data.copyBytes(to: buffer, from: bytesRead..<bytesRead+MemoryLayout<UInt16>.stride)
        }
        withUnsafeMutablePointer(to: &width) {
            let buffer = UnsafeMutableBufferPointer(start: $0, count: 1)
            bytesRead += data.copyBytes(to: buffer, from: bytesRead..<bytesRead+MemoryLayout<UInt16>.stride)
        }
        withUnsafeMutablePointer(to: &height) {
            let buffer = UnsafeMutableBufferPointer(start: $0, count: 1)
            bytesRead += data.copyBytes(to: buffer, from: bytesRead..<bytesRead+MemoryLayout<UInt16>.stride)
        }
        withUnsafeMutablePointer(to: &bitsperpixel) {
            let buffer = UnsafeMutableBufferPointer(start: $0, count: 1)
            bytesRead += data.copyBytes(to: buffer, from: bytesRead..<bytesRead+MemoryLayout<UInt8>.stride)
        }
        withUnsafeMutablePointer(to: &imagedescriptor) {
            let buffer = UnsafeMutableBufferPointer(start: $0, count: 1)
            bytesRead += data.copyBytes(to: buffer, from: bytesRead..<bytesRead+MemoryLayout<UInt8>.stride)
        }
        return bytesRead
    }
}

public struct TGAColour {
    public var bgra: [UInt8] = [0, 0, 0, 0]
    public var b: UInt8 {
        get {
            return bgra[0]
        }
        set(newValue) {
            bgra[0] = newValue
        }
    }
    public var g: UInt8 {
        get {
            return bgra[1]
        }
        set(newValue) {
            bgra[1] = newValue
        }
    }
    public var r: UInt8 {
        get {
            return bgra[2]
        }
        set(newValue) {
            bgra[2] = newValue
        }
    }
    public var a: UInt8 {
        get {
            return bgra[3]
        }
        set(newValue) {
            bgra[3] = newValue
        }
    }
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

    mutating func read(from data: Data, at i: Int, bpp: UInt8) -> Bool {
        if i + Int(bpp) >= data.count {
            return false
        }
        for j in 0..<Int(bpp) {
            bgra[j] = data[i + j]
        }
        self.bpp = bpp
        return true
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

    public mutating func read(fromFile filename: String) -> Bool {
        guard let data = FileManager.default.contents(atPath: filename) else {
            print("Failed to read file \(filename)")
            return false
        }
        var header = TGAHeader()
        let bytesRead = header.read(from: data)
        if bytesRead == 0 {
            print("Failed to read image header.")
            return false
        }
        width = Int(header.width)
        height = Int(header.height)
        bpp = header.bitsperpixel >> 3
        if width <= 0 || height <= 0 || (bpp != Format.grayscale.rawValue && bpp != Format.rgb.rawValue && bpp != Format.rgba.rawValue) {
            print("Invalid image header.")
            return false
        }
        let nbytes = width * height * Int(bpp)
        bytes = [UInt8](repeating: 0, count: nbytes)
        if header.datatypecode == 3 || header.datatypecode == 2 {
            data.copyBytes(to: &bytes, from: bytesRead..<nbytes)
            return true
        } else if header.datatypecode == 11 || header.datatypecode == 10 {
            if !loadRleData(from: data, at: bytesRead) {
                print("Failed to read RLE data.")
                return false
            }
        } else {
            print("Unknown file format: \(Int(header.datatypecode))")
            return false
        }
        if (header.imagedescriptor & 0x20) == 0 {
            flipVertically()
        }
        if (header.imagedescriptor & 0x10) != 0 {
            flipHorizontally()
        }
        print("\(width)x\(height)/\(bpp * 8)")
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

    public func get(x: Int, y: Int) -> TGAColour {
        if bytes.count == 0 || x < 0 || y < 0 || x >= width || y >= width {
            return TGAColour()
        }
        var colour = TGAColour(r: 0, g: 0, b: 0, a: 0, bpp: bpp)
        let i = (x + y * width) * Int(bpp)
        for j in 0..<Int(bpp) {
            colour.bgra[j] = bytes[i + j]
        }
        return colour
    }

    public mutating func setHorizUnsafe(x0: Int, x1: Int, y: Int, to colour: UnsafeBufferPointer<UInt8>)
    {
        assert(bytes.count != 0)
        assert(x0 >= 0 && x0 < width)
        assert(x1 >= 0 && x1 >= x0 && x1 < width)
        assert(y >= 0 && y < height);
        assert(bpp == 3)
        let start = (x0 + y * width) * Int(bpp)
        let end = (x1 + y * width) * Int(bpp)
        bytes.withUnsafeMutableBufferPointer {
            for i in start...end {
                $0[i] = colour[0]
                $0[i + 1] = colour[1]
                $0[i + 2] = colour[2]
            }
        }
    }

    @discardableResult
    public mutating func set(x: Int, y: Int, to colour: TGAColour) -> Bool {
        if bytes.count == 0 || x < 0 || y < 0 || x >= width || y >= height {
            return false
        }
        let i = (x + y * width) * Int(bpp)
        for j in 0..<Int(bpp) {
            bytes[i + j] = colour.bgra[j]
        }
        return true
    }

    private mutating func loadRleData(from data: Data, at start: Int) -> Bool {
        let pixelcount = width * height
        var currentpixel = 0
        var currentbyte = 0
        var colourbuffer = TGAColour()
        var i = start
        repeat {
            var chunkheader = UInt8()
            if i >= data.count { return false }
            chunkheader = data[i]
            i += 1
            if chunkheader < 128 {
                chunkheader += 1
                for _ in 0..<chunkheader {
                    if !colourbuffer.read(from: data, at: i, bpp: bpp) {
                        return false
                    }
                    i += Int(bpp)
                    if bpp >= 1 { bytes[currentbyte    ] = colourbuffer.b }
                    if bpp >= 2 { bytes[currentbyte + 1] = colourbuffer.g }
                    if bpp >= 3 { bytes[currentbyte + 2] = colourbuffer.r }
                    if bpp >= 4 { bytes[currentbyte + 3] = colourbuffer.a }
                    currentbyte += Int(bpp)
                    currentpixel += 1
                    if currentpixel > pixelcount {
                        print("Read too many pixels.")
                        return false
                    }
                }
            } else {
                chunkheader -= 127
                if !colourbuffer.read(from: data, at: i, bpp: bpp) {
                    return false
                }
                i += Int(bpp)
                for _ in 0..<chunkheader {
                    if bpp >= 1 { bytes[currentbyte    ] = colourbuffer.b }
                    if bpp >= 2 { bytes[currentbyte + 1] = colourbuffer.g }
                    if bpp >= 3 { bytes[currentbyte + 2] = colourbuffer.r }
                    if bpp >= 4 { bytes[currentbyte + 3] = colourbuffer.a }
                    currentbyte += Int(bpp)
                    currentpixel += 1
                    if currentpixel > pixelcount {
                        print("Read too many pixels.")
                    }
                }
            }
        } while currentpixel < pixelcount
        return true
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