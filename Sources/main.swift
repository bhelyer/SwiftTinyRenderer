import Foundation

// Parse command line arguments.
func printUsageAndExit() {
    print("usage: tinyrenderer [-b] model_file.obj")
    print("\t-b\t\tBenchmark, over render 1000000 times.")
    exit(1)
}

if CommandLine.arguments.count < 2 {
    printUsageAndExit()
}

var modelFilename = ""
var benchmark = false
if CommandLine.arguments.count == 2 {
    modelFilename = CommandLine.arguments[1]
} else {
    assert(CommandLine.arguments.count > 2)
    if CommandLine.arguments[1] == "-b" {
        modelFilename = CommandLine.arguments[2]
        benchmark = true
    } else if CommandLine.arguments[2] == "-b" {
        modelFilename = CommandLine.arguments[1]
        benchmark = true
    } else {
        printUsageAndExit()
    }
}
var renderCount = benchmark ? 10000 : 1

// Actually do the rendering.
let model = Model(fromFile: modelFilename)
var renderer = Renderer(width: 800, height: 800)
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