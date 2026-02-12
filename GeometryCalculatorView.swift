import SwiftUI
import SceneKit

// MARK: - Main Geometry Calculator View

struct GeometryCalculatorView: View {
    @State private var selectedCategory: ShapeCategory = .shapes2D
    @State private var selected2DShape: Shape2DType = .circle
    @State private var selected3DShape: Shape3DType = .sphere
    @State private var inputFields: [String: String] = [:]
    @State private var calculatedProperties: [String: String] = [:]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                categorySelector
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                shapeSelector
                    .padding(.horizontal, 20)
                
                visualizationArea
                    .padding(.horizontal, 20)
                
                inputFieldsArea
                    .padding(.horizontal, 20)
                
                if !calculatedProperties.isEmpty {
                    resultsArea
                        .padding(.horizontal, 20)
                        .transition(.scale.combined(with: .opacity))
                }
                
                calculateButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
            }
        }
        .background(Color.clear)
        .onTapGesture {
            // Dismiss keyboard when tapping outside
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    private var categorySelector: some View {
        HStack(spacing: 12) {
            ForEach(ShapeCategory.allCases, id: \.self) { category in
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        selectedCategory = category
                        calculatedProperties = [:]
                        inputFields = [:]
                    }
                }) {
                    Text(category.displayName)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(selectedCategory == category ? Color(hex: "#0F0F1E") : .white.opacity(0.7))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    selectedCategory == category ?
                                        LinearGradient(
                                            colors: [Color(hex: "#FF6B35"), Color(hex: "#F7931E")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ) :
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                )
                                .shadow(
                                    color: selectedCategory == category ? Color(hex: "#FF6B35").opacity(0.5) : Color.clear,
                                    radius: 10,
                                    y: 5
                                )
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private var shapeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                if selectedCategory == .shapes2D {
                    ForEach(Shape2DType.allCases, id: \.self) { shape in
                        ShapeButton(
                            name: shape.rawValue,
                            isSelected: selected2DShape == shape
                        ) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                selected2DShape = shape
                                calculatedProperties = [:]
                                inputFields = [:]
                            }
                        }
                    }
                } else {
                    ForEach(Shape3DType.allCases, id: \.self) { shape in
                        ShapeButton(
                            name: shape.rawValue,
                            isSelected: selected3DShape == shape
                        ) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                selected3DShape = shape
                                calculatedProperties = [:]
                                inputFields = [:]
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    private var visualizationArea: some View {
        VStack {
            if selectedCategory == .shapes2D {
                Shape2DVisualization(shapeType: selected2DShape, inputs: inputFields)
                    .frame(height: 280)
            } else {
                Shape3DVisualization(shapeType: selected3DShape, inputs: inputFields)
                    .frame(height: 320)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#1A1A2E").opacity(0.6), Color(hex: "#16213E").opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.2), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: Color.black.opacity(0.3), radius: 20, y: 10)
    }
    
    private var inputFieldsArea: some View {
        VStack(spacing: 12) {
            let fields = getInputFields()
            ForEach(fields, id: \.0) { field in
                GeometryInputField(
                    label: field.0,
                    value: Binding(
                        get: { inputFields[field.1] ?? "" },
                        set: { inputFields[field.1] = $0 }
                    )
                )
            }
        }
    }
    
    private var resultsArea: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Wyniki")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                ForEach(Array(calculatedProperties.sorted(by: { $0.key < $1.key })), id: \.key) { property in
                    HStack {
                        Text(property.key)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Spacer()
                        
                        Text(property.value)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(hex: "#00D9FF"))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "#1A1A2E").opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "#00D9FF").opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: Color(hex: "#00D9FF").opacity(0.2), radius: 15, y: 8)
    }
    
    private var calculateButton: some View {
        Button(action: calculateProperties) {
            HStack {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 20, weight: .semibold))
                Text("Oblicz")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
            }
            .foregroundColor(Color(hex: "#0F0F1E"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#00D9FF"), Color(hex: "#00A8CC")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color(hex: "#00D9FF").opacity(0.5), radius: 15, y: 8)
            )
        }
        .buttonStyle(PressEffectButtonStyle())
    }
    
    private func getInputFields() -> [(String, String)] {
        if selectedCategory == .shapes2D {
            switch selected2DShape {
            case .circle: return [("Promień", "radius")]
            case .square: return [("Bok", "side")]
            case .rectangle: return [("Szerokość", "width"), ("Wysokość", "height")]
            case .triangle: return [("Bok A", "sideA"), ("Bok B", "sideB"), ("Bok C", "sideC")]
            case .trapezoid: return [("Podstawa A", "baseA"), ("Podstawa B", "baseB"), ("Wysokość", "height"), ("Bok C", "sideC"), ("Bok D", "sideD")]
            }
        } else {
            switch selected3DShape {
            case .sphere: return [("Promień", "radius")]
            case .cube: return [("Krawędź", "side")]
            case .cylinder: return [("Promień", "radius"), ("Wysokość", "height")]
            case .cone: return [("Promień", "radius"), ("Wysokość", "height")]
            case .prism: return [("Szerokość", "width"), ("Wysokość", "height"), ("Głębokość", "depth")]
            case .pyramid: return [("Długość podstawy", "baseLength"), ("Szerokość podstawy", "baseWidth"), ("Wysokość", "height")]
            }
        }
    }
    
    private func calculateProperties() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            if selectedCategory == .shapes2D {
                calculate2DShape()
            } else {
                calculate3DShape()
            }
        }
    }
    
    private func calculate2DShape() {
        switch selected2DShape {
        case .circle:
            var circle = Circle2D()
            circle.radius = Double(inputFields["radius"] ?? "")
            calculatedProperties = circle.properties()
        case .square:
            var square = Square2D()
            square.side = Double(inputFields["side"] ?? "")
            calculatedProperties = square.properties()
        case .rectangle:
            var rect = Rectangle2D()
            rect.width = Double(inputFields["width"] ?? "")
            rect.height = Double(inputFields["height"] ?? "")
            calculatedProperties = rect.properties()
        case .triangle:
            var triangle = Triangle2D()
            triangle.sideA = Double(inputFields["sideA"] ?? "")
            triangle.sideB = Double(inputFields["sideB"] ?? "")
            triangle.sideC = Double(inputFields["sideC"] ?? "")
            calculatedProperties = triangle.properties()
        case .trapezoid:
            var trapezoid = Trapezoid2D()
            trapezoid.baseA = Double(inputFields["baseA"] ?? "")
            trapezoid.baseB = Double(inputFields["baseB"] ?? "")
            trapezoid.height = Double(inputFields["height"] ?? "")
            trapezoid.sideC = Double(inputFields["sideC"] ?? "")
            trapezoid.sideD = Double(inputFields["sideD"] ?? "")
            calculatedProperties = trapezoid.properties()
        }
    }
    
    private func calculate3DShape() {
        switch selected3DShape {
        case .sphere:
            var sphere = Sphere3D()
            sphere.radius = Double(inputFields["radius"] ?? "")
            calculatedProperties = sphere.properties()
        case .cube:
            var cube = Cube3D()
            cube.side = Double(inputFields["side"] ?? "")
            calculatedProperties = cube.properties()
        case .cylinder:
            var cylinder = Cylinder3D()
            cylinder.radius = Double(inputFields["radius"] ?? "")
            cylinder.height = Double(inputFields["height"] ?? "")
            calculatedProperties = cylinder.properties()
        case .cone:
            var cone = Cone3D()
            cone.radius = Double(inputFields["radius"] ?? "")
            cone.height = Double(inputFields["height"] ?? "")
            calculatedProperties = cone.properties()
        case .prism:
            var prism = RectangularPrism3D()
            prism.width = Double(inputFields["width"] ?? "")
            prism.height = Double(inputFields["height"] ?? "")
            prism.depth = Double(inputFields["depth"] ?? "")
            calculatedProperties = prism.properties()
        case .pyramid:
            var pyramid = Pyramid3D()
            pyramid.baseLength = Double(inputFields["baseLength"] ?? "")
            pyramid.baseWidth = Double(inputFields["baseWidth"] ?? "")
            pyramid.height = Double(inputFields["height"] ?? "")
            calculatedProperties = pyramid.properties()
        }
    }
}

// MARK: - Shape Button

struct ShapeButton: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(isSelected ? Color(hex: "#FF6B35").opacity(0.5) : Color.white.opacity(0.1))
                        .overlay(
                            Capsule()
                                .stroke(isSelected ? Color(hex: "#FF6B35") : Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: isSelected ? Color(hex: "#FF6B35").opacity(0.4) : Color.clear, radius: 8, y: 4)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Geometry Input Field

struct GeometryInputField: View {
    let label: String
    @Binding var value: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
            
            HStack(spacing: 8) {
                TextField("", text: $value)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .focused($isFocused)
                
                // OK button to dismiss keyboard
                if isFocused {
                    Button(action: {
                        isFocused = false
                    }) {
                        Text("OK")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#0F0F1E"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: "#00D9FF"))
                            )
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isFocused ? Color(hex: "#00D9FF") : Color(hex: "#00D9FF").opacity(0.3), lineWidth: isFocused ? 2 : 1)
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: isFocused)
        }
    }
}

// MARK: - 2D Visualization with Dimensions
// Note: PressEffectButtonStyle is defined in ContentView.swift

struct Shape2DVisualization: View {
    let shapeType: Shape2DType
    let inputs: [String: String]
    
    private let primaryGradient = LinearGradient(
        colors: [Color(hex: "#00D9FF"), Color(hex: "#FF6B35")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    private let dimensionColor = Color(hex: "#FFD700")
    private let labelColor = Color.white
    
    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
            ZStack {
                switch shapeType {
                case .circle:
                    CircleVisualization(center: center, inputs: inputs)
                case .square:
                    SquareVisualization(center: center, inputs: inputs)
                case .rectangle:
                    RectangleVisualization(center: center, inputs: inputs)
                case .triangle:
                    TriangleVisualization(center: center, geometry: geometry, inputs: inputs)
                case .trapezoid:
                    TrapezoidVisualization(center: center, geometry: geometry, inputs: inputs)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Circle Visualization

struct CircleVisualization: View {
    let center: CGPoint
    let inputs: [String: String]
    
    private var radiusValue: String {
        if let r = inputs["radius"], !r.isEmpty {
            return "r = \(r)"
        }
        return "r"
    }
    
    private var diameterValue: String {
        if let r = inputs["radius"], let rDouble = Double(r) {
            return "d = \(String(format: "%.1f", rDouble * 2))"
        }
        return "d = 2r"
    }
    
    var body: some View {
        let circleSize: CGFloat = 160
        let cx = center.x
        let cy = center.y
        
        ZStack {
            // Main circle
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [Color(hex: "#00D9FF"), Color(hex: "#FF6B35")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(width: circleSize, height: circleSize)
                .position(x: cx, y: cy)
                .shadow(color: Color(hex: "#00D9FF").opacity(0.5), radius: 15)
            
            // Center point
            Circle()
                .fill(Color(hex: "#FFD700"))
                .frame(width: 8, height: 8)
                .position(x: cx, y: cy)
            
            // Radius line (from center to right edge)
            Path { path in
                path.move(to: CGPoint(x: cx, y: cy))
                path.addLine(to: CGPoint(x: cx + circleSize/2, y: cy))
            }
            .stroke(Color(hex: "#FFD700"), style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
            
            // Radius label
            Text(radiusValue)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#FFD700"))
                .position(x: cx + circleSize/4, y: cy - 18)
            
            // Diameter label (below circle)
            Text(diameterValue)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
                .position(x: cx, y: cy + circleSize/2 + 25)
        }
    }
}

// MARK: - Square Visualization

struct SquareVisualization: View {
    let center: CGPoint
    let inputs: [String: String]
    
    private var sideValue: String {
        if let s = inputs["side"], !s.isEmpty {
            return "a = \(s)"
        }
        return "a"
    }
    
    var body: some View {
        let size: CGFloat = 140
        let cx = center.x
        let cy = center.y
        
        ZStack {
            // Main square
            Rectangle()
                .stroke(
                    LinearGradient(
                        colors: [Color(hex: "#00D9FF"), Color(hex: "#FF6B35")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(width: size, height: size)
                .position(x: cx, y: cy)
                .shadow(color: Color(hex: "#00D9FF").opacity(0.5), radius: 15)
            
            // Left dimension line
            Path { path in
                // Vertical line
                path.move(to: CGPoint(x: cx - size/2 - 20, y: cy - size/2))
                path.addLine(to: CGPoint(x: cx - size/2 - 20, y: cy + size/2))
                // Top cap
                path.move(to: CGPoint(x: cx - size/2 - 25, y: cy - size/2))
                path.addLine(to: CGPoint(x: cx - size/2 - 15, y: cy - size/2))
                // Bottom cap
                path.move(to: CGPoint(x: cx - size/2 - 25, y: cy + size/2))
                path.addLine(to: CGPoint(x: cx - size/2 - 15, y: cy + size/2))
            }
            .stroke(Color(hex: "#FFD700"), lineWidth: 1.5)
            
            // Left label
            Text(sideValue)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#FFD700"))
                .position(x: cx - size/2 - 45, y: cy)
            
            // Bottom dimension line
            Path { path in
                // Horizontal line
                path.move(to: CGPoint(x: cx - size/2, y: cy + size/2 + 20))
                path.addLine(to: CGPoint(x: cx + size/2, y: cy + size/2 + 20))
                // Left cap
                path.move(to: CGPoint(x: cx - size/2, y: cy + size/2 + 15))
                path.addLine(to: CGPoint(x: cx - size/2, y: cy + size/2 + 25))
                // Right cap
                path.move(to: CGPoint(x: cx + size/2, y: cy + size/2 + 15))
                path.addLine(to: CGPoint(x: cx + size/2, y: cy + size/2 + 25))
            }
            .stroke(Color(hex: "#FFD700"), lineWidth: 1.5)
            
            // Bottom label
            Text(sideValue)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#FFD700"))
                .position(x: cx, y: cy + size/2 + 40)
            
            // Diagonal line (przekątna)
            Path { path in
                path.move(to: CGPoint(x: cx - size/2, y: cy - size/2))
                path.addLine(to: CGPoint(x: cx + size/2, y: cy + size/2))
            }
            .stroke(Color.white.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
            
            // Right angle marker
            Path { path in
                path.move(to: CGPoint(x: cx - size/2 + 15, y: cy + size/2))
                path.addLine(to: CGPoint(x: cx - size/2 + 15, y: cy + size/2 - 15))
                path.addLine(to: CGPoint(x: cx - size/2, y: cy + size/2 - 15))
            }
            .stroke(Color(hex: "#FFD700"), lineWidth: 1.5)
        }
    }
}

// MARK: - Rectangle Visualization

struct RectangleVisualization: View {
    let center: CGPoint
    let inputs: [String: String]
    
    private var widthValue: String {
        if let w = inputs["width"], !w.isEmpty {
            return "a = \(w)"
        }
        return "a"
    }
    
    private var heightValue: String {
        if let h = inputs["height"], !h.isEmpty {
            return "b = \(h)"
        }
        return "b"
    }
    
    var body: some View {
        let width: CGFloat = 180
        let height: CGFloat = 110
        let cx = center.x
        let cy = center.y
        
        ZStack {
            // Main rectangle
            Rectangle()
                .stroke(
                    LinearGradient(
                        colors: [Color(hex: "#00D9FF"), Color(hex: "#FF6B35")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(width: width, height: height)
                .position(x: cx, y: cy)
                .shadow(color: Color(hex: "#00D9FF").opacity(0.5), radius: 15)
            
            // Left dimension line (height)
            Path { path in
                // Vertical line
                path.move(to: CGPoint(x: cx - width/2 - 20, y: cy - height/2))
                path.addLine(to: CGPoint(x: cx - width/2 - 20, y: cy + height/2))
                // Top cap
                path.move(to: CGPoint(x: cx - width/2 - 25, y: cy - height/2))
                path.addLine(to: CGPoint(x: cx - width/2 - 15, y: cy - height/2))
                // Bottom cap
                path.move(to: CGPoint(x: cx - width/2 - 25, y: cy + height/2))
                path.addLine(to: CGPoint(x: cx - width/2 - 15, y: cy + height/2))
            }
            .stroke(Color(hex: "#FFD700"), lineWidth: 1.5)
            
            // Left label (height)
            Text(heightValue)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#FFD700"))
                .position(x: cx - width/2 - 45, y: cy)
            
            // Bottom dimension line (width)
            Path { path in
                // Horizontal line
                path.move(to: CGPoint(x: cx - width/2, y: cy + height/2 + 20))
                path.addLine(to: CGPoint(x: cx + width/2, y: cy + height/2 + 20))
                // Left cap
                path.move(to: CGPoint(x: cx - width/2, y: cy + height/2 + 15))
                path.addLine(to: CGPoint(x: cx - width/2, y: cy + height/2 + 25))
                // Right cap
                path.move(to: CGPoint(x: cx + width/2, y: cy + height/2 + 15))
                path.addLine(to: CGPoint(x: cx + width/2, y: cy + height/2 + 25))
            }
            .stroke(Color(hex: "#FFD700"), lineWidth: 1.5)
            
            // Bottom label (width)
            Text(widthValue)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#FFD700"))
                .position(x: cx, y: cy + height/2 + 40)
            
            // Right angle marker
            Path { path in
                path.move(to: CGPoint(x: cx - width/2 + 15, y: cy + height/2))
                path.addLine(to: CGPoint(x: cx - width/2 + 15, y: cy + height/2 - 15))
                path.addLine(to: CGPoint(x: cx - width/2, y: cy + height/2 - 15))
            }
            .stroke(Color(hex: "#FFD700"), lineWidth: 1.5)
        }
    }
}

// MARK: - Triangle Visualization

struct TriangleVisualization: View {
    let center: CGPoint
    let geometry: GeometryProxy
    let inputs: [String: String]
    
    private func sideLabel(_ key: String, prefix: String) -> String {
        if let v = inputs[key], !v.isEmpty {
            return "\(prefix) = \(v)"
        }
        return prefix
    }
    
    var body: some View {
        let width: CGFloat = 160
        let height: CGFloat = 140
        let centerX = geometry.size.width / 2
        let centerY = geometry.size.height / 2
        
        // Triangle vertices
        let topPoint = CGPoint(x: centerX, y: centerY - height/2)
        let leftPoint = CGPoint(x: centerX - width/2, y: centerY + height/2)
        let rightPoint = CGPoint(x: centerX + width/2, y: centerY + height/2)
        
        ZStack {
            // Main triangle
            Path { path in
                path.move(to: topPoint)
                path.addLine(to: leftPoint)
                path.addLine(to: rightPoint)
                path.closeSubpath()
            }
            .stroke(
                LinearGradient(
                    colors: [Color(hex: "#00D9FF"), Color(hex: "#FF6B35")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 3
            )
            .shadow(color: Color(hex: "#00D9FF").opacity(0.5), radius: 15)
            
            // Side A label (left side)
            Text(sideLabel("sideA", prefix: "a"))
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#FFD700"))
                .position(x: centerX - width/2 - 25, y: centerY)
            
            // Side B label (right side)
            Text(sideLabel("sideB", prefix: "b"))
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#FFD700"))
                .position(x: centerX + width/2 + 25, y: centerY)
            
            // Side C label (bottom)
            Text(sideLabel("sideC", prefix: "c"))
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#FFD700"))
                .position(x: centerX, y: centerY + height/2 + 20)
            
            // Height line (dashed)
            Path { path in
                path.move(to: topPoint)
                path.addLine(to: CGPoint(x: centerX, y: centerY + height/2))
            }
            .stroke(Color.white.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
            
            // Height label
            Text("h")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
                .position(x: centerX + 15, y: centerY)
        }
    }
}

// MARK: - Trapezoid Visualization

struct TrapezoidVisualization: View {
    let center: CGPoint
    let geometry: GeometryProxy
    let inputs: [String: String]
    
    var body: some View {
        let topWidth: CGFloat = 100
        let bottomWidth: CGFloat = 160
        let height: CGFloat = 110
        let centerX = geometry.size.width / 2
        let centerY = geometry.size.height / 2
        
        ZStack {
            // Main trapezoid
            Path { path in
                path.move(to: CGPoint(x: centerX - topWidth/2, y: centerY - height/2))
                path.addLine(to: CGPoint(x: centerX + topWidth/2, y: centerY - height/2))
                path.addLine(to: CGPoint(x: centerX + bottomWidth/2, y: centerY + height/2))
                path.addLine(to: CGPoint(x: centerX - bottomWidth/2, y: centerY + height/2))
                path.closeSubpath()
            }
            .stroke(
                LinearGradient(
                    colors: [Color(hex: "#00D9FF"), Color(hex: "#FF6B35")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 3
            )
            .shadow(color: Color(hex: "#00D9FF").opacity(0.5), radius: 15)
            
            // Base A (top)
            Text(inputs["baseA"].map { "a = \($0)" } ?? "a")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#FFD700"))
                .position(x: centerX, y: centerY - height/2 - 18)
            
            // Base B (bottom)
            Text(inputs["baseB"].map { "b = \($0)" } ?? "b")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#FFD700"))
                .position(x: centerX, y: centerY + height/2 + 18)
            
            // Height line
            Path { path in
                path.move(to: CGPoint(x: centerX, y: centerY - height/2))
                path.addLine(to: CGPoint(x: centerX, y: centerY + height/2))
            }
            .stroke(Color.white.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
            
            // Height label
            Text(inputs["height"].map { "h = \($0)" } ?? "h")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#FFD700"))
                .position(x: centerX + 25, y: centerY)
            
            // Side labels
            Text("c")
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
                .position(x: centerX - bottomWidth/2 - 18, y: centerY)
            
            Text("d")
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
                .position(x: centerX + bottomWidth/2 + 18, y: centerY)
        }
    }
}

// MARK: - Dimension Line Component

struct DimensionLine: View {
    let start: CGPoint
    let end: CGPoint
    let label: String
    let labelOffset: CGPoint
    let isVertical: Bool
    
    var body: some View {
        ZStack {
            // Main line
            Path { path in
                path.move(to: start)
                path.addLine(to: end)
            }
            .stroke(Color(hex: "#FFD700"), lineWidth: 1.5)
            
            // End caps
            if isVertical {
                // Top cap
                Path { path in
                    path.move(to: CGPoint(x: start.x - 5, y: start.y))
                    path.addLine(to: CGPoint(x: start.x + 5, y: start.y))
                }
                .stroke(Color(hex: "#FFD700"), lineWidth: 1.5)
                
                // Bottom cap
                Path { path in
                    path.move(to: CGPoint(x: end.x - 5, y: end.y))
                    path.addLine(to: CGPoint(x: end.x + 5, y: end.y))
                }
                .stroke(Color(hex: "#FFD700"), lineWidth: 1.5)
            } else {
                // Left cap
                Path { path in
                    path.move(to: CGPoint(x: start.x, y: start.y - 5))
                    path.addLine(to: CGPoint(x: start.x, y: start.y + 5))
                }
                .stroke(Color(hex: "#FFD700"), lineWidth: 1.5)
                
                // Right cap
                Path { path in
                    path.move(to: CGPoint(x: end.x, y: end.y - 5))
                    path.addLine(to: CGPoint(x: end.x, y: end.y + 5))
                }
                .stroke(Color(hex: "#FFD700"), lineWidth: 1.5)
            }
            
            // Label
            let midPoint = CGPoint(x: (start.x + end.x) / 2 + labelOffset.x,
                                   y: (start.y + end.y) / 2 + labelOffset.y)
            Text(label)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#FFD700"))
                .position(midPoint)
        }
    }
}

// MARK: - Dimension Arrow

struct DimensionArrow: View {
    let start: CGPoint
    let end: CGPoint
    
    var body: some View {
        Path { path in
            path.move(to: start)
            path.addLine(to: end)
        }
        .stroke(Color(hex: "#FFD700").opacity(0.5), lineWidth: 1)
    }
}

// MARK: - 3D Visualization with SceneKit

struct Shape3DVisualization: View {
    let shapeType: Shape3DType
    let inputs: [String: String]
    
    var body: some View {
        ZStack {
            SceneKitView(shapeType: shapeType, inputs: inputs)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            
            // Dimension labels overlay
            VStack {
                Spacer()
                HStack {
                    dimensionLabels
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(0.5))
                        )
                    Spacer()
                }
                .padding(16)
            }
            
            // Rotation hint
            VStack {
                HStack {
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "hand.draw")
                            .font(.system(size: 12))
                        Text("Obróć")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(.white.opacity(0.5))
                    .padding(8)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.3))
                    )
                }
                .padding(12)
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private var dimensionLabels: some View {
        VStack(alignment: .leading, spacing: 6) {
            switch shapeType {
            case .sphere:
                DimensionLabel(name: "Promień", symbol: "r", value: inputs["radius"])
                
            case .cube:
                DimensionLabel(name: "Krawędź", symbol: "a", value: inputs["side"])
                
            case .cylinder:
                DimensionLabel(name: "Promień", symbol: "r", value: inputs["radius"])
                DimensionLabel(name: "Wysokość", symbol: "h", value: inputs["height"])
                
            case .cone:
                DimensionLabel(name: "Promień", symbol: "r", value: inputs["radius"])
                DimensionLabel(name: "Wysokość", symbol: "h", value: inputs["height"])
                
            case .prism:
                DimensionLabel(name: "Szerokość", symbol: "a", value: inputs["width"])
                DimensionLabel(name: "Wysokość", symbol: "b", value: inputs["height"])
                DimensionLabel(name: "Głębokość", symbol: "c", value: inputs["depth"])
                
            case .pyramid:
                DimensionLabel(name: "Podstawa", symbol: "a×b", value: nil, compound: (inputs["baseLength"], inputs["baseWidth"]))
                DimensionLabel(name: "Wysokość", symbol: "h", value: inputs["height"])
            }
        }
    }
}

// MARK: - Dimension Label

struct DimensionLabel: View {
    let name: String
    let symbol: String
    var value: String?
    var compound: (String?, String?)? = nil
    
    var body: some View {
        HStack(spacing: 8) {
            Text(symbol)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#FFD700"))
                .frame(width: 30, alignment: .leading)
            
            if let compound = compound {
                let l = compound.0 ?? "?"
                let w = compound.1 ?? "?"
                Text("\(l) × \(w)")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
            } else if let v = value, !v.isEmpty {
                Text("= \(v)")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
            } else {
                Text(name)
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }
}

// MARK: - SceneKit View

struct SceneKitView: UIViewRepresentable {
    let shapeType: Shape3DType
    let inputs: [String: String]
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.backgroundColor = .clear
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = false
        scnView.antialiasingMode = .multisampling4X
        scnView.preferredFramesPerSecond = 60
        
        let scene = SCNScene()
        scnView.scene = scene
        
        setupScene(scene: scene)
        
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        guard let scene = uiView.scene else { return }
        
        // Remove old shape node
        scene.rootNode.childNodes.filter { $0.name == "shapeNode" }.forEach { $0.removeFromParentNode() }
        
        // Add new shape
        let shapeNode = createShapeNode()
        shapeNode.name = "shapeNode"
        scene.rootNode.addChildNode(shapeNode)
        
        // Add rotation animation
        let rotation = CABasicAnimation(keyPath: "rotation")
        rotation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Float.pi * 2))
        rotation.duration = 10
        rotation.repeatCount = .infinity
        shapeNode.addAnimation(rotation, forKey: "autoRotate")
    }
    
    private func setupScene(scene: SCNScene) {
        // Camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0.5, z: 4)
        cameraNode.camera?.fieldOfView = 45
        scene.rootNode.addChildNode(cameraNode)
        
        // Ambient light - BRIGHTER
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = UIColor(white: 0.6, alpha: 1.0)
        ambientLight.light?.intensity = 500
        scene.rootNode.addChildNode(ambientLight)
        
        // Main directional light - BRIGHTER
        let mainLight = SCNNode()
        mainLight.light = SCNLight()
        mainLight.light?.type = .directional
        mainLight.light?.color = UIColor.white
        mainLight.light?.intensity = 1200
        mainLight.position = SCNVector3(x: 5, y: 5, z: 5)
        mainLight.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(mainLight)
        
        // Fill light - BRIGHTER cyan
        let fillLight = SCNNode()
        fillLight.light = SCNLight()
        fillLight.light?.type = .directional
        fillLight.light?.color = UIColor(hex: "#00D9FF") ?? .cyan
        fillLight.light?.intensity = 600
        fillLight.position = SCNVector3(x: -3, y: 2, z: -3)
        fillLight.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(fillLight)
        
        // Front light - NEW for better visibility
        let frontLight = SCNNode()
        frontLight.light = SCNLight()
        frontLight.light?.type = .directional
        frontLight.light?.color = UIColor.white
        frontLight.light?.intensity = 400
        frontLight.position = SCNVector3(x: 0, y: 0, z: 5)
        frontLight.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(frontLight)
        
        // Rim light
        let rimLight = SCNNode()
        rimLight.light = SCNLight()
        rimLight.light?.type = .directional
        rimLight.light?.color = UIColor(hex: "#FF6B35") ?? .orange
        rimLight.light?.intensity = 300
        rimLight.position = SCNVector3(x: 0, y: -3, z: -4)
        rimLight.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(rimLight)
        
        // Add shape
        let shapeNode = createShapeNode()
        shapeNode.name = "shapeNode"
        scene.rootNode.addChildNode(shapeNode)
        
        // Auto rotation animation
        let rotation = CABasicAnimation(keyPath: "rotation")
        rotation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Float.pi * 2))
        rotation.duration = 10
        rotation.repeatCount = .infinity
        shapeNode.addAnimation(rotation, forKey: "autoRotate")
    }
    
    private func createShapeNode() -> SCNNode {
        let geometry: SCNGeometry
        
        switch shapeType {
        case .sphere:
            let radius = CGFloat(Double(inputs["radius"] ?? "") ?? 1.0)
            let normalizedRadius = min(max(radius / 5.0, 0.5), 1.5)
            geometry = SCNSphere(radius: normalizedRadius)
            (geometry as! SCNSphere).segmentCount = 64
            
        case .cube:
            let side = CGFloat(Double(inputs["side"] ?? "") ?? 1.0)
            let normalizedSide = min(max(side / 5.0, 0.8), 2.0)
            geometry = SCNBox(width: normalizedSide, height: normalizedSide, length: normalizedSide, chamferRadius: 0.02)
            
        case .cylinder:
            let radius = CGFloat(Double(inputs["radius"] ?? "") ?? 1.0)
            let height = CGFloat(Double(inputs["height"] ?? "") ?? 2.0)
            let normalizedRadius = min(max(radius / 5.0, 0.3), 1.0)
            let normalizedHeight = min(max(height / 5.0, 0.5), 2.5)
            geometry = SCNCylinder(radius: normalizedRadius, height: normalizedHeight)
            (geometry as! SCNCylinder).radialSegmentCount = 48
            
        case .cone:
            let radius = CGFloat(Double(inputs["radius"] ?? "") ?? 1.0)
            let height = CGFloat(Double(inputs["height"] ?? "") ?? 2.0)
            let normalizedRadius = min(max(radius / 5.0, 0.3), 1.0)
            let normalizedHeight = min(max(height / 5.0, 0.5), 2.5)
            geometry = SCNCone(topRadius: 0, bottomRadius: normalizedRadius, height: normalizedHeight)
            (geometry as! SCNCone).radialSegmentCount = 48
            
        case .prism:
            let width = CGFloat(Double(inputs["width"] ?? "") ?? 2.0)
            let height = CGFloat(Double(inputs["height"] ?? "") ?? 1.0)
            let depth = CGFloat(Double(inputs["depth"] ?? "") ?? 1.5)
            let normalizedWidth = min(max(width / 5.0, 0.5), 2.0)
            let normalizedHeight = min(max(height / 5.0, 0.3), 1.5)
            let normalizedDepth = min(max(depth / 5.0, 0.4), 1.8)
            geometry = SCNBox(width: normalizedWidth, height: normalizedHeight, length: normalizedDepth, chamferRadius: 0.01)
            
        case .pyramid:
            let baseLength = CGFloat(Double(inputs["baseLength"] ?? "") ?? 2.0)
            let baseWidth = CGFloat(Double(inputs["baseWidth"] ?? "") ?? 2.0)
            let height = CGFloat(Double(inputs["height"] ?? "") ?? 2.0)
            let normalizedBase = min(max((baseLength + baseWidth) / 10.0, 0.5), 1.5)
            let normalizedHeight = min(max(height / 5.0, 0.5), 2.0)
            geometry = SCNPyramid(width: normalizedBase, height: normalizedHeight, length: normalizedBase)
        }
        
        // Material - BRIGHT version
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(hex: "#4ECDC4") ?? .cyan  // Bright teal
        material.specular.contents = UIColor.white
        material.shininess = 0.8
        material.fresnelExponent = 1.5
        material.reflective.contents = UIColor(hex: "#00D9FF")?.withAlphaComponent(0.3)
        material.isDoubleSided = false
        material.lightingModel = .physicallyBased
        material.metalness.contents = 0.2
        material.roughness.contents = 0.3
        
        geometry.materials = [material]
        
        // Wireframe overlay
        let wireframeMaterial = SCNMaterial()
        wireframeMaterial.diffuse.contents = UIColor.clear
        wireframeMaterial.emission.contents = UIColor(hex: "#00D9FF")?.withAlphaComponent(0.3)
        wireframeMaterial.fillMode = .lines
        
        let node = SCNNode(geometry: geometry)
        
        // Add wireframe node
        let wireframeGeometry = geometry.copy() as! SCNGeometry
        wireframeGeometry.materials = [wireframeMaterial]
        let wireframeNode = SCNNode(geometry: wireframeGeometry)
        wireframeNode.scale = SCNVector3(1.001, 1.001, 1.001)
        node.addChildNode(wireframeNode)
        
        return node
    }
}

// MARK: - UIColor Extension (Color extension is in ContentView.swift)

extension UIColor {
    convenience init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}
