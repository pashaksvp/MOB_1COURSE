import Foundation

struct ExpressionParser {
    static func parse(_ input: String) -> Expression? {
        let trimmed = input.replacingOccurrences(of: " ", with: "")

        for op in ["+", "-", "*", "/", "%"] {
            if let range = trimmed.range(of: op) {
                let lhs = String(trimmed[..<range.lowerBound])
                let rhs = String(trimmed[range.upperBound...])
                guard let leftExpr = parse(lhs), let rightExpr = parse(rhs) else { return nil }

                return .binary(op: BinaryOp(rawValue: op)!, lhs: leftExpr, rhs: rightExpr)
            }
        }

        if let intVal = Int(trimmed) {
            return .constant(intVal)
        } else {
            return .variable(trimmed)
        }
    }
}
