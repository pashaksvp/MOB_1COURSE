struct ExpressionParser {
    private static var tokens: [String] = []
    private static var current = 0

    static func parse(_ input: String) -> Expression? {
        tokens = tokenize(input)
        current = 0
        return parseExpression()
    }


    private static func parseExpression() -> Expression? {
        return parseAddSubtract()
    }

    private static func parseAddSubtract() -> Expression? {
        var expr = parseMultiplyDivide()

        while match("+", "-") {
            let opStr = previous()
            let op = BinaryOp(rawValue: opStr)!
            guard let right = parseMultiplyDivide() else { return nil }
            expr = .binary(op: op, lhs: expr!, rhs: right)
        }

        return expr
    }

    private static func parseMultiplyDivide() -> Expression? {
        var expr = parsePrimary()

        while match("*", "/", "%") {
            let opStr = previous()
            let op = BinaryOp(rawValue: opStr)!
            guard let right = parsePrimary() else { return nil }
            expr = .binary(op: op, lhs: expr!, rhs: right)
        }

        return expr
    }

    private static func parsePrimary() -> Expression? {
        if match("(") {
            guard let expr = parseExpression(), match(")") else { return nil }
            return expr
        }

        if let token = advance() {
            if let intVal = Int(token) {
                return .constant(intVal)
            } else {
                return .variable(token)
            }
        }

        return nil
    }

    private static func tokenize(_ input: String) -> [String] {
        var result: [String] = []
        var current = ""

        for char in input {
            if char.isWhitespace { continue }

            if "+-*/()%".contains(char) {
                if !current.isEmpty {
                    result.append(current)
                    current = ""
                }
                result.append(String(char))
            } else {
                current.append(char)
            }
        }

        if !current.isEmpty {
            result.append(current)
        }

        return result
    }


    private static func match(_ expected: String...) -> Bool {
        guard !isAtEnd else { return false }
        if expected.contains(tokens[current]) {
            current += 1
            return true
        }
        return false
    }

    private static func advance() -> String? {
        guard !isAtEnd else { return nil }
        let token = tokens[current]
        current += 1
        return token
    }

    private static func previous() -> String {
        return tokens[current - 1]
    }

    private static var isAtEnd: Bool {
        return current >= tokens.count
    }
}
