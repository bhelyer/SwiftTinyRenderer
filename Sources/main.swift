import Foundation

if CommandLine.arguments.count != 2 {
    print("usage: tinyrenderer model_file.obj")
    exit(1)
}

let model = Model(fromFile: CommandLine.arguments[1])
var renderer = Renderer(width: 800, height: 800)
renderer.render(model: model)
do {
    try renderer.saveScreenshot(to: "output.tga")
} catch {
    print("Failed to write image.")
}