import SwiftUI

struct StandardCalculatorView: View {
    @StateObject private var calculator = CalculatorEngine()
    @State private var showHistory = false
    @State private var buttonPresses: [String: Bool] = [:]
    
    let buttons: [[CalculatorButton]] = [
        [.clear, .delete, .percent, .divide],
        [.seven, .eight, .nine, .multiply],
        [.four, .five, .six, .subtract],
        [.one, .two, .three, .add],
        [.zero, .decimal, .equals]
    ]
    
    let scientificButtons: [[CalculatorButton]] = [
        [.sin, .cos, .tan, .ln],
        [.log, .sqrt, .power, .factorial]
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {
                    displayArea
                        .frame(height: geometry.size.height * 0.35)
                    
                    Spacer()
                    
                    scientificFunctionsArea
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                    
                    calculatorButtonsArea(geometry: geometry)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                }
                
                if showHistory {
                    HistoryView(history: calculator.history, isShowing: $showHistory)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                        .zIndex(10)
                }
            }
        }
    }
    
    private var displayArea: some View {
        VStack(alignment: .trailing, spacing: 12) {
            HStack {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        calculator.angleMode = calculator.angleMode == .degrees ? .radians : .degrees
                    }
                }) {
                    Text(calculator.angleMode == .degrees ? "DEG" : "RAD")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(calculator.angleMode == .degrees ? Color(hex: "#FF6B35") : Color(hex: "#00D9FF"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    Capsule()
                                        .stroke(
                                            calculator.angleMode == .degrees ? Color(hex: "#FF6B35") : Color(hex: "#00D9FF"),
                                            lineWidth: 2
                                        )
                                )
                        )
                }
                .buttonStyle(PressEffectButtonStyle())
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        showHistory.toggle()
                    }
                }) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(12)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(PressEffectButtonStyle())
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            Spacer()
            
            ScrollView(.horizontal, showsIndicators: false) {
                Text(calculator.display)
                    .font(.system(size: min(70, 800 / CGFloat(max(calculator.display.count, 1))), weight: .light, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .padding(.horizontal, 24)
            }
            .frame(height: 100)
            
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "#00D9FF").opacity(0.6),
                            Color(hex: "#00A8CC").opacity(0.3),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)
                .padding(.horizontal, 24)
                .shadow(color: Color(hex: "#00D9FF").opacity(0.8), radius: 10, y: 0)
        }
    }
    
    private var scientificFunctionsArea: some View {
        VStack(spacing: 8) {
            ForEach(scientificButtons.indices, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(scientificButtons[row], id: \.self) { button in
                        ScientificButton(
                            button: button,
                            isPressed: buttonPresses[button.rawValue] ?? false
                        ) {
                            handleButtonTap(button)
                        }
                    }
                }
            }
        }
    }
    
    private func calculatorButtonsArea(geometry: GeometryProxy) -> some View {
        VStack(spacing: 12) {
            ForEach(buttons.indices, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(buttons[row], id: \.self) { button in
                        CalculatorButtonView(
                            button: button,
                            isPressed: buttonPresses[button.rawValue] ?? false
                        ) {
                            handleButtonTap(button)
                        }
                        .frame(
                            width: buttonWidth(button: button, geometry: geometry),
                            height: buttonHeight(geometry: geometry)
                        )
                    }
                }
            }
        }
    }
    
    private func buttonWidth(button: CalculatorButton, geometry: GeometryProxy) -> CGFloat {
        let spacing: CGFloat = 12
        let totalSpacing = spacing * 3
        let availableWidth = geometry.size.width - 40 - totalSpacing
        
        if button == .zero {
            return (availableWidth / 4) * 2 + spacing
        }
        return availableWidth / 4
    }
    
    private func buttonHeight(geometry: GeometryProxy) -> CGFloat {
        let spacing: CGFloat = 12
        let totalSpacing = spacing * 4
        let availableHeight = geometry.size.height * 0.5
        return (availableHeight - totalSpacing) / 5
    }
    
    private func handleButtonTap(_ button: CalculatorButton) {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        withAnimation(.easeInOut(duration: 0.1)) {
            buttonPresses[button.rawValue] = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeInOut(duration: 0.1)) {
                buttonPresses[button.rawValue] = false
            }
        }
        
        switch button {
        case .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine:
            calculator.inputNumber(button.rawValue)
        case .decimal:
            calculator.inputNumber(".")
        case .add:
            calculator.inputOperation(.add)
        case .subtract:
            // ZMIENIONE - inteligentny minus
            if calculator.canAddMinusAtStart() {
                calculator.inputNumber("-")
            } else {
                calculator.inputOperation(.subtract)
            }
        case .multiply:
            calculator.inputOperation(.multiply)
        case .divide:
            calculator.inputOperation(.divide)
        case .equals:
            withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) {
                calculator.calculate()
            }
        case .clear:
            withAnimation(.easeOut(duration: 0.3)) {
                calculator.clear()
            }
        case .delete:
            calculator.delete()
        case .negate:
            calculator.negate()
        case .percent:
            calculator.inputOperation(.percent)
            calculator.calculate()
        case .sin:
            calculator.inputOperation(.sin)
            calculator.calculate()
        case .cos:
            calculator.inputOperation(.cos)
            calculator.calculate()
        case .tan:
            calculator.inputOperation(.tan)
            calculator.calculate()
        case .ln:
            calculator.inputOperation(.ln)
            calculator.calculate()
        case .log:
            calculator.inputOperation(.log)
            calculator.calculate()
        case .sqrt:
            calculator.inputOperation(.root)
            calculator.calculate()
        case .power:
            calculator.inputOperation(.power)
        case .factorial:
            calculator.inputOperation(.factorial)
            calculator.calculate()
        }
    }
}

enum CalculatorButton: String {
    case zero = "0", one = "1", two = "2", three = "3", four = "4"
    case five = "5", six = "6", seven = "7", eight = "8", nine = "9"
    case decimal = "."
    case add = "+", subtract = "-", multiply = "×", divide = "÷"
    case equals = "="
    case clear = "C", delete = "⌫", negate = "+/-", percent = "%"
    case sin = "sin", cos = "cos", tan = "tan"
    case ln = "ln", log = "log", sqrt = "√", power = "^", factorial = "!"
    
    var backgroundColor: Color {
        switch self {
        case .add, .subtract, .multiply, .divide, .equals:
            return Color(hex: "#00D9FF")
        case .clear, .delete, .percent:
            return Color(hex: "#E53935")
        default:
            return Color.white.opacity(0.15)
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .add, .subtract, .multiply, .divide, .equals:
            return Color(hex: "#0F0F1E")
        default:
            return .white
        }
    }
}

struct CalculatorButtonView: View {
    let button: CalculatorButton
    let isPressed: Bool
    let action: () -> Void
    
    @State private var scale: CGFloat = 1
    @State private var opacity: Double = 1
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if button.backgroundColor == Color(hex: "#00D9FF") {
                    Circle()
                        .fill(Color(hex: "#00D9FF").opacity(0.3))
                        .blur(radius: 15)
                        .scaleEffect(isPressed ? 0.9 : 1.1)
                }
                
                RoundedRectangle(cornerRadius: button == .zero ? 40 : 20)
                    .fill(button.backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: button == .zero ? 40 : 20)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.3), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: button.backgroundColor == Color(hex: "#00D9FF") ?
                            Color(hex: "#00D9FF").opacity(0.5) : Color.black.opacity(0.3),
                        radius: isPressed ? 5 : 10,
                        y: isPressed ? 2 : 5
                    )
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                
                Text(button.rawValue)
                    .font(.system(size: 28, weight: .medium, design: .rounded))
                    .foregroundColor(button.foregroundColor)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(scale)
        .opacity(opacity)
    }
}

struct ScientificButton: View {
    let button: CalculatorButton
    let isPressed: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(button.rawValue)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "#FF6B35").opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "#FF6B35").opacity(0.5), lineWidth: 1)
                        )
                        .shadow(color: Color(hex: "#FF6B35").opacity(0.3), radius: isPressed ? 3 : 8, y: isPressed ? 1 : 4)
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct HistoryView: View {
    let history: [String]
    @Binding var isShowing: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        isShowing = false
                    }
                }
            
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Historia")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            isShowing = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(24)
                .background(Color(hex: "#1A1A2E"))
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(history.indices, id: \.self) { index in
                            Text(history[index])
                                .font(.system(size: 16, weight: .regular, design: .monospaced))
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.vertical, 12)
                                .padding(.horizontal, 20)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.05))
                                )
                        }
                    }
                    .padding(20)
                }
                .background(Color(hex: "#0F0F1E"))
            }
            .frame(width: UIScreen.main.bounds.width * 0.85)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.5), radius: 30, y: 10)
        }
    }
}

struct PressEffectButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
