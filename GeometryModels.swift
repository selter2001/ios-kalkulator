import Foundation
import SwiftUI

// MARK: - 2D Shape Protocol

protocol Shape2D {
    var name: String { get }
    func area() -> Double?
    func perimeter() -> Double?
    func properties() -> [String: String]
}

// MARK: - 3D Shape Protocol

protocol Shape3D {
    var name: String { get }
    func volume() -> Double?
    func surfaceArea() -> Double?
    func properties() -> [String: String]
}

// MARK: - 2D Shapes

struct Circle2D: Shape2D {
    let name = "Koło"
    var radius: Double?
    
    func area() -> Double? {
        guard let r = radius else { return nil }
        return Double.pi * r * r
    }
    
    func perimeter() -> Double? {
        guard let r = radius else { return nil }
        return 2 * Double.pi * r
    }
    
    func properties() -> [String: String] {
        var props: [String: String] = [:]
        if let a = area() { props["Pole"] = String(format: "%.2f", a) }
        if let p = perimeter() { props["Obwód"] = String(format: "%.2f", p) }
        if let r = radius {
            props["Promień"] = String(format: "%.2f", r)
            props["Średnica"] = String(format: "%.2f", r * 2)
        }
        return props
    }
}

struct Rectangle2D: Shape2D {
    let name = "Prostokąt"
    var width: Double?
    var height: Double?
    
    func area() -> Double? {
        guard let w = width, let h = height else { return nil }
        return w * h
    }
    
    func perimeter() -> Double? {
        guard let w = width, let h = height else { return nil }
        return 2 * (w + h)
    }
    
    func properties() -> [String: String] {
        var props: [String: String] = [:]
        if let a = area() { props["Pole"] = String(format: "%.2f", a) }
        if let p = perimeter() { props["Obwód"] = String(format: "%.2f", p) }
        if let w = width, let h = height {
            props["Szerokość"] = String(format: "%.2f", w)
            props["Wysokość"] = String(format: "%.2f", h)
            props["Przekątna"] = String(format: "%.2f", sqrt(w*w + h*h))
        }
        return props
    }
}

struct Triangle2D: Shape2D {
    let name = "Trójkąt"
    var sideA, sideB, sideC: Double?
    
    func area() -> Double? {
        guard let a = sideA, let b = sideB, let c = sideC else { return nil }
        let s = (a + b + c) / 2
        let areaSquared = s * (s - a) * (s - b) * (s - c)
        return areaSquared > 0 ? sqrt(areaSquared) : nil
    }
    
    func perimeter() -> Double? {
        guard let a = sideA, let b = sideB, let c = sideC else { return nil }
        return a + b + c
    }
    
    func properties() -> [String: String] {
        var props: [String: String] = [:]
        if let a = area() { props["Pole"] = String(format: "%.2f", a) }
        if let p = perimeter() { props["Obwód"] = String(format: "%.2f", p) }
        return props
    }
}

struct Square2D: Shape2D {
    let name = "Kwadrat"
    var side: Double?
    
    func area() -> Double? {
        guard let s = side else { return nil }
        return s * s
    }
    
    func perimeter() -> Double? {
        guard let s = side else { return nil }
        return 4 * s
    }
    
    func properties() -> [String: String] {
        var props: [String: String] = [:]
        if let a = area() { props["Pole"] = String(format: "%.2f", a) }
        if let p = perimeter() { props["Obwód"] = String(format: "%.2f", p) }
        if let s = side {
            props["Bok"] = String(format: "%.2f", s)
            props["Przekątna"] = String(format: "%.2f", s * sqrt(2))
        }
        return props
    }
}

struct Trapezoid2D: Shape2D {
    let name = "Trapez"
    var baseA, baseB, height, sideC, sideD: Double?
    
    func area() -> Double? {
        guard let a = baseA, let b = baseB, let h = height else { return nil }
        return ((a + b) / 2) * h
    }
    
    func perimeter() -> Double? {
        guard let a = baseA, let b = baseB, let c = sideC, let d = sideD else { return nil }
        return a + b + c + d
    }
    
    func properties() -> [String: String] {
        var props: [String: String] = [:]
        if let a = area() { props["Pole"] = String(format: "%.2f", a) }
        if let p = perimeter() { props["Obwód"] = String(format: "%.2f", p) }
        return props
    }
}

// MARK: - 3D Shapes

struct Sphere3D: Shape3D {
    let name = "Kula"
    var radius: Double?
    
    func volume() -> Double? {
        guard let r = radius else { return nil }
        return (4.0 / 3.0) * Double.pi * r * r * r
    }
    
    func surfaceArea() -> Double? {
        guard let r = radius else { return nil }
        return 4 * Double.pi * r * r
    }
    
    func properties() -> [String: String] {
        var props: [String: String] = [:]
        if let v = volume() { props["Objętość"] = String(format: "%.2f", v) }
        if let a = surfaceArea() { props["Pole powierzchni"] = String(format: "%.2f", a) }
        if let r = radius { props["Promień"] = String(format: "%.2f", r) }
        return props
    }
}

struct Cube3D: Shape3D {
    let name = "Sześcian"
    var side: Double?
    
    func volume() -> Double? {
        guard let s = side else { return nil }
        return s * s * s
    }
    
    func surfaceArea() -> Double? {
        guard let s = side else { return nil }
        return 6 * s * s
    }
    
    func properties() -> [String: String] {
        var props: [String: String] = [:]
        if let v = volume() { props["Objętość"] = String(format: "%.2f", v) }
        if let a = surfaceArea() { props["Pole powierzchni"] = String(format: "%.2f", a) }
        if let s = side {
            props["Krawędź"] = String(format: "%.2f", s)
            props["Przekątna"] = String(format: "%.2f", s * sqrt(3))
        }
        return props
    }
}

struct Cylinder3D: Shape3D {
    let name = "Walec"
    var radius, height: Double?
    
    func volume() -> Double? {
        guard let r = radius, let h = height else { return nil }
        return Double.pi * r * r * h
    }
    
    func surfaceArea() -> Double? {
        guard let r = radius, let h = height else { return nil }
        return 2 * Double.pi * r * (r + h)
    }
    
    func properties() -> [String: String] {
        var props: [String: String] = [:]
        if let v = volume() { props["Objętość"] = String(format: "%.2f", v) }
        if let a = surfaceArea() { props["Pole powierzchni"] = String(format: "%.2f", a) }
        if let r = radius { props["Promień"] = String(format: "%.2f", r) }
        if let h = height { props["Wysokość"] = String(format: "%.2f", h) }
        return props
    }
}

struct Cone3D: Shape3D {
    let name = "Stożek"
    var radius, height: Double?
    
    func volume() -> Double? {
        guard let r = radius, let h = height else { return nil }
        return (1.0 / 3.0) * Double.pi * r * r * h
    }
    
    func surfaceArea() -> Double? {
        guard let r = radius, let h = height else { return nil }
        let slant = sqrt(r * r + h * h)
        return Double.pi * r * (r + slant)
    }
    
    func properties() -> [String: String] {
        var props: [String: String] = [:]
        if let v = volume() { props["Objętość"] = String(format: "%.2f", v) }
        if let a = surfaceArea() { props["Pole powierzchni"] = String(format: "%.2f", a) }
        if let r = radius { props["Promień"] = String(format: "%.2f", r) }
        if let h = height {
            props["Wysokość"] = String(format: "%.2f", h)
            if let r = radius {
                props["Tworząca"] = String(format: "%.2f", sqrt(r*r + h*h))
            }
        }
        return props
    }
}

struct RectangularPrism3D: Shape3D {
    let name = "Prostopadłościan"
    var width, height, depth: Double?
    
    func volume() -> Double? {
        guard let w = width, let h = height, let d = depth else { return nil }
        return w * h * d
    }
    
    func surfaceArea() -> Double? {
        guard let w = width, let h = height, let d = depth else { return nil }
        return 2 * (w * h + h * d + d * w)
    }
    
    func properties() -> [String: String] {
        var props: [String: String] = [:]
        if let v = volume() { props["Objętość"] = String(format: "%.2f", v) }
        if let a = surfaceArea() { props["Pole powierzchni"] = String(format: "%.2f", a) }
        if let w = width { props["Szerokość"] = String(format: "%.2f", w) }
        if let h = height { props["Wysokość"] = String(format: "%.2f", h) }
        if let d = depth { props["Głębokość"] = String(format: "%.2f", d) }
        if let w = width, let h = height, let d = depth {
            props["Przekątna"] = String(format: "%.2f", sqrt(w*w + h*h + d*d))
        }
        return props
    }
}

struct Pyramid3D: Shape3D {
    let name = "Ostrosłup"
    var baseLength, baseWidth, height: Double?
    
    func volume() -> Double? {
        guard let l = baseLength, let w = baseWidth, let h = height else { return nil }
        return (1.0 / 3.0) * l * w * h
    }
    
    func surfaceArea() -> Double? {
        guard let l = baseLength, let w = baseWidth, let h = height else { return nil }
        return l * w + l * sqrt((w/2)*(w/2) + h*h) + w * sqrt((l/2)*(l/2) + h*h)
    }
    
    func properties() -> [String: String] {
        var props: [String: String] = [:]
        if let v = volume() { props["Objętość"] = String(format: "%.2f", v) }
        if let a = surfaceArea() { props["Pole powierzchni"] = String(format: "%.2f", a) }
        if let l = baseLength { props["Długość podstawy"] = String(format: "%.2f", l) }
        if let w = baseWidth { props["Szerokość podstawy"] = String(format: "%.2f", w) }
        if let h = height { props["Wysokość"] = String(format: "%.2f", h) }
        return props
    }
}

// MARK: - Enums

enum ShapeCategory: String, CaseIterable {
    case shapes2D = "2D"
    case shapes3D = "3D"
    
    var displayName: String {
        switch self {
        case .shapes2D: return "Figury 2D"
        case .shapes3D: return "Bryły 3D"
        }
    }
}

enum Shape2DType: String, CaseIterable {
    case circle = "Koło"
    case square = "Kwadrat"
    case rectangle = "Prostokąt"
    case triangle = "Trójkąt"
    case trapezoid = "Trapez"
}

enum Shape3DType: String, CaseIterable {
    case sphere = "Kula"
    case cube = "Sześcian"
    case cylinder = "Walec"
    case cone = "Stożek"
    case prism = "Prostopadłościan"
    case pyramid = "Ostrosłup"
}
