struct ConditionParser {
    static func parse(_ input: String) -> Condition? {
        let operators: [String: ComparisonOp] = [
            "==": .equal,
            "!=": .notEqual,
            ">=": .greaterOrEqual,
            "<=": .lessOrEqual,
            ">": .greater,
            "<": .less
        ]

        for (opStr, op) in operators {
            if let range = input.range(of: opStr) {
                let lhsStr = String(input[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
                let rhsStr = String(input[range.upperBound...]).trimmingCharacters(in: .whitespaces)
                if let lhs = ExpressionParser.parse(lhsStr), let rhs = ExpressionParser.parse(rhsStr) {
                    return .comparison(lhs: lhs, op: op, rhs: rhs)
                }
            }
        }

        return nil
    }
}
