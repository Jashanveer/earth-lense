import AppKit
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let outputDirectory = root
    .appendingPathComponent("EarthLens", isDirectory: true)
    .appendingPathComponent("Assets.xcassets", isDirectory: true)
    .appendingPathComponent("AppIcon.appiconset", isDirectory: true)

try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

struct IconSlot {
    let idiom = "mac"
    let size: String
    let scale: String
    let pixels: Int
    let filename: String
}

let slots: [IconSlot] = [
    .init(size: "16x16", scale: "1x", pixels: 16, filename: "icon_16x16.png"),
    .init(size: "16x16", scale: "2x", pixels: 32, filename: "icon_16x16@2x.png"),
    .init(size: "32x32", scale: "1x", pixels: 32, filename: "icon_32x32.png"),
    .init(size: "32x32", scale: "2x", pixels: 64, filename: "icon_32x32@2x.png"),
    .init(size: "128x128", scale: "1x", pixels: 128, filename: "icon_128x128.png"),
    .init(size: "128x128", scale: "2x", pixels: 256, filename: "icon_128x128@2x.png"),
    .init(size: "256x256", scale: "1x", pixels: 256, filename: "icon_256x256.png"),
    .init(size: "256x256", scale: "2x", pixels: 512, filename: "icon_256x256@2x.png"),
    .init(size: "512x512", scale: "1x", pixels: 512, filename: "icon_512x512.png"),
    .init(size: "512x512", scale: "2x", pixels: 1024, filename: "icon_512x512@2x.png")
]

func color(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1) -> NSColor {
    NSColor(calibratedRed: red, green: green, blue: blue, alpha: alpha)
}

func drawIcon(size: Int) -> NSImage {
    let canvas = CGFloat(size)
    let image = NSImage(size: NSSize(width: canvas, height: canvas))

    image.lockFocus()
    guard let context = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }

    context.setAllowsAntialiasing(true)
    context.setShouldAntialias(true)

    let rect = CGRect(x: 0, y: 0, width: canvas, height: canvas)
    let cornerRadius = canvas * 0.225
    let iconShape = CGPath(
        roundedRect: rect.insetBy(dx: canvas * 0.035, dy: canvas * 0.035),
        cornerWidth: cornerRadius,
        cornerHeight: cornerRadius,
        transform: nil
    )

    context.saveGState()
    context.addPath(iconShape)
    context.clip()

    let background = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [
            color(0.015, 0.08, 0.18).cgColor,
            color(0.02, 0.23, 0.34).cgColor,
            color(0.02, 0.45, 0.46).cgColor
        ] as CFArray,
        locations: [0, 0.56, 1]
    )!
    context.drawLinearGradient(
        background,
        start: CGPoint(x: canvas * 0.08, y: canvas * 0.92),
        end: CGPoint(x: canvas * 0.9, y: canvas * 0.08),
        options: []
    )

    let glow = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [
            color(0.22, 0.82, 0.95, 0.62).cgColor,
            color(0.08, 0.34, 0.48, 0).cgColor
        ] as CFArray,
        locations: [0, 1]
    )!
    context.drawRadialGradient(
        glow,
        startCenter: CGPoint(x: canvas * 0.68, y: canvas * 0.68),
        startRadius: 0,
        endCenter: CGPoint(x: canvas * 0.68, y: canvas * 0.68),
        endRadius: canvas * 0.62,
        options: []
    )

    let globeRect = CGRect(x: canvas * 0.18, y: canvas * 0.17, width: canvas * 0.64, height: canvas * 0.64)
    let globePath = CGPath(ellipseIn: globeRect, transform: nil)
    context.addPath(globePath)
    context.clip()

    let globe = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [
            color(0.10, 0.78, 0.93).cgColor,
            color(0.03, 0.36, 0.66).cgColor,
            color(0.03, 0.13, 0.34).cgColor
        ] as CFArray,
        locations: [0, 0.55, 1]
    )!
    context.drawLinearGradient(
        globe,
        start: CGPoint(x: globeRect.minX, y: globeRect.maxY),
        end: CGPoint(x: globeRect.maxX, y: globeRect.minY),
        options: []
    )

    func drawLand(_ points: [CGPoint], fill: NSColor) {
        guard let first = points.first else { return }
        let path = CGMutablePath()
        path.move(to: first)
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        path.closeSubpath()
        context.addPath(path)
        context.setFillColor(fill.cgColor)
        context.fillPath()
    }

    let land = color(0.20, 0.72, 0.50, 0.92)
    let landDeep = color(0.08, 0.47, 0.41, 0.9)
    drawLand([
        CGPoint(x: canvas * 0.29, y: canvas * 0.62),
        CGPoint(x: canvas * 0.42, y: canvas * 0.72),
        CGPoint(x: canvas * 0.54, y: canvas * 0.66),
        CGPoint(x: canvas * 0.48, y: canvas * 0.54),
        CGPoint(x: canvas * 0.36, y: canvas * 0.50)
    ], fill: land)
    drawLand([
        CGPoint(x: canvas * 0.55, y: canvas * 0.50),
        CGPoint(x: canvas * 0.72, y: canvas * 0.56),
        CGPoint(x: canvas * 0.74, y: canvas * 0.39),
        CGPoint(x: canvas * 0.61, y: canvas * 0.32),
        CGPoint(x: canvas * 0.50, y: canvas * 0.39)
    ], fill: landDeep)
    drawLand([
        CGPoint(x: canvas * 0.28, y: canvas * 0.37),
        CGPoint(x: canvas * 0.40, y: canvas * 0.45),
        CGPoint(x: canvas * 0.47, y: canvas * 0.34),
        CGPoint(x: canvas * 0.38, y: canvas * 0.25),
        CGPoint(x: canvas * 0.27, y: canvas * 0.27)
    ], fill: land)

    context.resetClip()

    let globeStroke = CGPath(ellipseIn: globeRect, transform: nil)
    context.addPath(globeStroke)
    context.setStrokeColor(color(0.80, 0.98, 1.0, 0.72).cgColor)
    context.setLineWidth(canvas * 0.018)
    context.strokePath()

    let orbitRect = globeRect.insetBy(dx: -canvas * 0.115, dy: canvas * 0.13)
    context.saveGState()
    context.translateBy(x: orbitRect.midX, y: orbitRect.midY)
    context.rotate(by: -0.62)
    context.translateBy(x: -orbitRect.midX, y: -orbitRect.midY)
    context.addEllipse(in: orbitRect)
    context.setStrokeColor(color(0.86, 1.0, 1.0, 0.78).cgColor)
    context.setLineWidth(canvas * 0.026)
    context.strokePath()
    context.restoreGState()

    let satelliteRect = CGRect(x: canvas * 0.73, y: canvas * 0.68, width: canvas * 0.075, height: canvas * 0.075)
    context.addEllipse(in: satelliteRect)
    context.setFillColor(color(0.92, 1.0, 1.0).cgColor)
    context.fillPath()

    context.addPath(iconShape)
    context.setStrokeColor(color(1, 1, 1, 0.24).cgColor)
    context.setLineWidth(canvas * 0.018)
    context.strokePath()

    context.restoreGState()
    image.unlockFocus()
    return image
}

func writePNG(_ image: NSImage, pixels: Int, to url: URL) throws {
    guard
        let tiff = image.tiffRepresentation,
        let bitmap = NSBitmapImageRep(data: tiff),
        let data = bitmap.representation(using: .png, properties: [:])
    else {
        throw NSError(domain: "IconGenerator", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not encode PNG"])
    }

    try data.write(to: url, options: .atomic)
}

for slot in slots {
    let image = drawIcon(size: slot.pixels)
    try writePNG(image, pixels: slot.pixels, to: outputDirectory.appendingPathComponent(slot.filename))
}

let images = slots.map { slot -> [String: String] in
    [
        "idiom": slot.idiom,
        "size": slot.size,
        "scale": slot.scale,
        "filename": slot.filename
    ]
}
let contents: [String: Any] = [
    "images": images,
    "info": [
        "author": "xcode",
        "version": 1
    ]
]
let json = try JSONSerialization.data(withJSONObject: contents, options: [.prettyPrinted, .sortedKeys])
try json.write(to: outputDirectory.appendingPathComponent("Contents.json"), options: .atomic)

print("Generated EarthLens app icon set at \(outputDirectory.path)")
