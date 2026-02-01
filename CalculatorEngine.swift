import Foundation
import Combine

// BigNumber implementation for arbitrary precision arithmetic
class BigNumber: CustomStringConvertible, Equatable {
    private var digits: [Int]
    private var isNegative: Bool
    private var decimalPlaces: Int
    
    init(_ value: String) {
        var cleaned = value.trimmingCharacters(in: .whitespaces)
        self.isNegative = cleaned.hasPrefix("-")
        if isNegative {
            cleaned.removeFirst()
        }
        
        let parts = cleaned.components(separatedBy: ".")
        let integerPart = parts[0]
        let fractionalPart = parts.count > 1 ? parts[1] : ""
        
        self.decimalPlaces = fractionalPart.count
        let combined = integerPart + fractionalPart
        
        self.digits = combined.compactMap { Int(String($0)) }.reversed()
        
        while digits.count > 1 && digits.last == 0 {
            digits.removeLast()
        }
        
        if digits.isEmpty {
            digits = [0]
            isNegative = false
        }
    }
    
    init(digits: [Int], isNegative: Bool, decimalPlaces: Int) {
        self.digits = digits
        self.isNegative = isNegative
        self.decimalPlaces = decimalPlaces
    }
    
    var description: String {
        var result = String(digits.reversed().map { String($0) }.joined())
        
        if decimalPlaces > 0 {
            let insertIndex = result.index(result.endIndex, offsetBy: -decimalPlaces)
            result.insert(".", at: insertIndex)
            
            while result.hasSuffix("0") && result.contains(".") {
                result.removeLast()
            }
            if result.hasSuffix(".") {
                result.removeLast()
            }
        }
        
        return (isNegative ? "-" : "") + (result.isEmpty ? "0" : result)
    }
    
    static func == (lhs: BigNumber, rhs: BigNumber) -> Bool {
        return lhs.digits == rhs.digits &&
               lhs.isNegative == rhs.isNegative &&
               lhs.decimalPlaces == rhs.decimalPlaces
    }
    
    static func + (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        var left = lhs.digits
        var right = rhs.digits
        let maxDecimal = max(lhs.decimalPlaces, rhs.decimalPlaces)
        
        while lhs.decimalPlaces < maxDecimal {
            left.insert(0, at: 0)
        }
        while rhs.decimalPlaces < maxDecimal {
            right.insert(0, at: 0)
        }
        
        if lhs.isNegative == rhs.isNegative {
            var result: [Int] = []
            var carry = 0
            let maxLen = max(left.count, right.count)
            
            for i in 0..<maxLen {
                let a = i < left.count ? left[i] : 0
                let b = i < right.count ? right[i] : 0
                let sum = a + b + carry
                result.append(sum % 10)
                carry = sum / 10
            }
            
            if carry > 0 {
                result.append(carry)
            }
            
            return BigNumber(digits: result, isNegative: lhs.isNegative, decimalPlaces: maxDecimal)
        } else {
            return lhs - BigNumber(digits: rhs.digits, isNegative: !rhs.isNegative, decimalPlaces: rhs.decimalPlaces)
        }
    }
    
    static func - (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        if lhs.isNegative != rhs.isNegative {
            return lhs + BigNumber(digits: rhs.digits, isNegative: !rhs.isNegative, decimalPlaces: rhs.decimalPlaces)
        }
        
        var left = lhs.digits
        var right = rhs.digits
        let maxDecimal = max(lhs.decimalPlaces, rhs.decimalPlaces)
        
        while lhs.decimalPlaces < maxDecimal {
            left.insert(0, at: 0)
        }
        while rhs.decimalPlaces < maxDecimal {
            right.insert(0, at: 0)
        }
        
        var isResultNegative = false
        if left.count < right.count {
            isResultNegative = !lhs.isNegative
            swap(&left, &right)
        } else if left.count == right.count {
            for i in stride(from: left.count - 1, through: 0, by: -1) {
                if left[i] < right[i] {
                    isResultNegative = !lhs.isNegative
                    swap(&left, &right)
                    break
                } else if left[i] > right[i] {
                    break
                }
            }
        }
        
        var result: [Int] = []
        var borrow = 0
        
        for i in 0..<left.count {
            let a = left[i]
            let b = i < right.count ? right[i] : 0
            var diff = a - b - borrow
            
            if diff < 0 {
                diff += 10
                borrow = 1
            } else {
                borrow = 0
            }
            
            result.append(diff)
        }
        
        while result.count > 1 && result.last == 0 {
            result.removeLast()
        }
        
        if result.count == 1 && result[0] == 0 {
            isResultNegative = false
        }
        
        return BigNumber(digits: result, isNegative: isResultNegative, decimalPlaces: maxDecimal)
    }
    
    static func * (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        var result = [Int](repeating: 0, count: lhs.digits.count + rhs.digits.count)
        
        for i in 0..<lhs.digits.count {
            var carry = 0
            for j in 0..<rhs.digits.count {
                let product = lhs.digits[i] * rhs.digits[j] + result[i + j] + carry
                result[i + j] = product % 10
                carry = product / 10
            }
            if carry > 0 {
                result[i + rhs.digits.count] += carry
            }
        }
        
        while result.count > 1 && result.last == 0 {
            result.removeLast()
        }
        
        let isNeg = lhs.isNegative != rhs.isNegative
        let decPlaces = lhs.decimalPlaces + rhs.decimalPlaces
        
        return BigNumber(digits: result, isNegative: isNeg, decimalPlaces: decPlaces)
    }
    
    static func / (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        guard let lhsDouble = Double(lhs.description),
              let rhsDouble = Double(rhs.description),
              rhsDouble != 0 else {
            return BigNumber("Error")
        }
        
        let result = lhsDouble / rhsDouble
        return BigNumber(String(result))
    }
}

class CalculatorEngine: ObservableObject {
    @Published var display: String = "0"
    @Published var history: [String] = []
    @Published var angleMode: AngleMode = .degrees
    
    private var currentNumber: String = ""
    private var previousNumber: String = ""
    private var operation: Operation?
    private var shouldResetDisplay = false
    
    enum AngleMode {
        case degrees
        case radians
    }
    
    enum Operation: String {
        case add = "+"
        case subtract = "-"
        case multiply = "×"
        case divide = "÷"
        case power = "^"
        case root = "√"
        case percent = "%"
        case sin, cos, tan
        case ln, log
        case factorial = "!"
    }
    
    // NOWA FUNKCJA - sprawdza czy można dodać minus na początku
    func canAddMinusAtStart() -> Bool {
        // Jeśli nie ma operacji (previousNumber pusty) i currentNumber jest pusty lub 0
        return previousNumber.isEmpty && (currentNumber.isEmpty || currentNumber == "0")
    }
    
    func inputNumber(_ number: String) {
        if shouldResetDisplay {
            currentNumber = ""
            shouldResetDisplay = false
        }
        
        if number == "." && currentNumber.contains(".") {
            return
        }
        
        if currentNumber == "0" && number != "." && number != "-" {
            currentNumber = number
        } else {
            currentNumber += number
        }
        
        updateDisplay()
    }
    
    func inputOperation(_ op: Operation) {
        if !currentNumber.isEmpty {
            if !previousNumber.isEmpty && operation != nil {
                calculate()
            }
            previousNumber = currentNumber
            currentNumber = ""
        }
        operation = op
        shouldResetDisplay = false
        updateDisplay()
    }
    
    func calculate() {
        guard !previousNumber.isEmpty else { return }
        
        let num1 = BigNumber(previousNumber)
        let num2 = currentNumber.isEmpty ? BigNumber("0") : BigNumber(currentNumber)
        
        var result: BigNumber
        
        switch operation {
        case .add:
            result = num1 + num2
        case .subtract:
            result = num1 - num2
        case .multiply:
            result = num1 * num2
        case .divide:
            result = num1 / num2
        case .power:
            result = power(num1, num2)
        case .sin:
            result = sine(num1)
        case .cos:
            result = cosine(num1)
        case .tan:
            result = tangent(num1)
        case .ln:
            result = naturalLog(num1)
        case .log:
            result = logarithm(num1)
        case .root:
            result = squareRoot(num1)
        case .percent:
            result = BigNumber(previousNumber) * BigNumber("0.01")
        case .factorial:
            result = factorial(num1)
        case .none:
            result = num2
        }
        
        let historyEntry = "\(previousNumber) \(operation?.rawValue ?? "") \(currentNumber) = \(result.description)"
        history.insert(historyEntry, at: 0)
        if history.count > 50 {
            history.removeLast()
        }
        
        display = result.description
        currentNumber = result.description
        previousNumber = ""
        operation = nil
        shouldResetDisplay = true
    }
    
    func clear() {
        display = "0"
        currentNumber = ""
        previousNumber = ""
        operation = nil
        shouldResetDisplay = false
    }
    
    func delete() {
        if !currentNumber.isEmpty && !shouldResetDisplay {
            currentNumber.removeLast()
            if currentNumber.isEmpty || currentNumber == "-" {
                currentNumber = "0"
            }
            updateDisplay()
        }
    }
    
    func negate() {
        // Pozwól na minus na początku
        if currentNumber == "0" || currentNumber.isEmpty {
            currentNumber = "-"
        } else if currentNumber == "-" {
            currentNumber = "0"
        } else if currentNumber.hasPrefix("-") {
            currentNumber.removeFirst()
        } else {
            currentNumber = "-" + currentNumber
        }
        updateDisplay()
    }
    
    private func updateDisplay() {
        if !previousNumber.isEmpty && operation != nil {
            // Show: "45 - 30" (full expression)
            display = "\(previousNumber) \(operation!.rawValue) \(currentNumber)"
        } else {
            // Show just current number
            display = currentNumber.isEmpty ? "0" : currentNumber
        }
    }
    
    private func power(_ base: BigNumber, _ exponent: BigNumber) -> BigNumber {
        guard let baseDouble = Double(base.description),
              let expDouble = Double(exponent.description) else {
            return BigNumber("0")
        }
        return BigNumber(String(pow(baseDouble, expDouble)))
    }
    
    private func sine(_ num: BigNumber) -> BigNumber {
        guard let value = Double(num.description) else { return BigNumber("0") }
        let radians = angleMode == .degrees ? value * .pi / 180 : value
        return BigNumber(String(sin(radians)))
    }
    
    private func cosine(_ num: BigNumber) -> BigNumber {
        guard let value = Double(num.description) else { return BigNumber("0") }
        let radians = angleMode == .degrees ? value * .pi / 180 : value
        return BigNumber(String(cos(radians)))
    }
    
    private func tangent(_ num: BigNumber) -> BigNumber {
        guard let value = Double(num.description) else { return BigNumber("0") }
        let radians = angleMode == .degrees ? value * .pi / 180 : value
        return BigNumber(String(tan(radians)))
    }
    
    private func naturalLog(_ num: BigNumber) -> BigNumber {
        guard let value = Double(num.description), value > 0 else { return BigNumber("0") }
        return BigNumber(String(log(value)))
    }
    
    private func logarithm(_ num: BigNumber) -> BigNumber {
        guard let value = Double(num.description), value > 0 else { return BigNumber("0") }
        return BigNumber(String(log10(value)))
    }
    
    private func squareRoot(_ num: BigNumber) -> BigNumber {
        guard let value = Double(num.description), value >= 0 else { return BigNumber("0") }
        return BigNumber(String(sqrt(value)))
    }
    
    private func factorial(_ num: BigNumber) -> BigNumber {
        guard let value = Int(num.description), value >= 0, value <= 170 else {
            return BigNumber("0")
        }
        
        var result = 1.0
        for i in 2...value {
            result *= Double(i)
        }
        return BigNumber(String(result))
    }
}
