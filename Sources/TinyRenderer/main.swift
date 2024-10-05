import Foundation

// Parse command line arguments.
func printUsageAndExit() {
    print("usage: tinyrenderer [-b] model_file.obj [texture_file.tga]")
    print("\t-b\t\tBenchmark, over render multiple times.")
    exit(1)
}

if CommandLine.arguments.count < 2 {
    printUsageAndExit()
}

var modelFilename = ""
var textureFilename = ""
var benchmark = false
for argument in CommandLine.arguments {
    if argument == "-b" {
        benchmark = true
    } else if argument.hasSuffix(".obj") {
        modelFilename = argument
    } else if argument.hasSuffix(".tga") {
        textureFilename = argument
    }
}

if modelFilename.isEmpty {
    printUsageAndExit()
}
var renderCount = benchmark ? 100 : 1
if benchmark {
    print("Benchmarking \(renderCount)")
}

// Actually do the rendering.
let model = Model(fromFile: modelFilename)
var renderer = Renderer(width: 800, height: 800)
if !textureFilename.isEmpty {
    do {
        print("Loading texture '\(textureFilename)'.")
        try renderer.loadTexture(from: textureFilename)
    } catch {
        print("Failed to load texture '\(textureFilename)'.")
    }
}
repeat {
    renderer.render(model: model)
    renderCount -= 1
} while renderCount > 0

// Save the render to a file.
do {
    try renderer.saveScreenshot(to: "output.tga")
} catch {
    print("Failed to write image.")
}
