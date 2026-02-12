import SwiftUI

enum CalculatorTab {
    case standard
    case geometry
}

struct ContentView: View {
    @State private var selectedTab: CalculatorTab = .standard
    
    var body: some View {
        ZStack {
            // Animated gradient background
            AnimatedGradientBackground(selectedTab: selectedTab)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Main content
                TabView(selection: $selectedTab) {
                    StandardCalculatorView()
                        .tag(CalculatorTab.standard)
                    
                    GeometryCalculatorView()
                        .tag(CalculatorTab.geometry)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: selectedTab)
                
                // Custom tab bar
                CustomTabBar(selectedTab: $selectedTab)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
            }
        }
    }
}

struct AnimatedGradientBackground: View {
    let selectedTab: CalculatorTab
    
    var body: some View {
        LinearGradient(
            colors: selectedTab == .standard ?
                [Color(hex: "#0F0F1E"), Color(hex: "#1A1A2E"), Color(hex: "#16213E")] :
                [Color(hex: "#16213E"), Color(hex: "#0F3460"), Color(hex: "#1A1A2E")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .animation(.easeInOut(duration: 0.8), value: selectedTab)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: CalculatorTab
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            TabButton(
                title: "Kalkulator",
                icon: "function",
                isSelected: selectedTab == .standard,
                namespace: animation
            ) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    selectedTab = .standard
                }
            }
            
            TabButton(
                title: "Geometria",
                icon: "cube.fill",
                isSelected: selectedTab == .geometry,
                namespace: animation
            ) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    selectedTab = .geometry
                }
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.3), radius: 20, y: 10)
        )
    }
}

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                
                if isSelected {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .foregroundColor(isSelected ? Color(hex: "#0F0F1E") : .white.opacity(0.6))
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "#00D9FF"), Color(hex: "#00A8CC")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .matchedGeometryEffect(id: "TAB", in: namespace)
                            .shadow(color: Color(hex: "#00D9FF").opacity(0.5), radius: 12, y: 6)
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Color extension for hex colors
extension Color {
    init(hex: String) {
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
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
