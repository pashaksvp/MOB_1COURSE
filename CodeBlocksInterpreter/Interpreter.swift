import Foundation

class Interpreter {
    var variables: [String: Int] = [:]

    func run(nodes: [ASTNode]) {
        for node in nodes {
            execute(node)
        }
    }

    private func execute(_ node: ASTNode) {
        switch node {
        case .variableDeclaration(let names):
            for name in names {
                if variables[name] == nil {
                    variables[name] = 0
                }
            }
        case .assignment(let variable, let expression):
            let value = evaluate(expression)
            variables[variable] = value
        case .ifStatement(let condition, let body):
            if evaluate(condition) {
                run(nodes: body)
            }
        }
    }

    private func evaluate(_ expression: Expression) -> Int {
        switch expression {
        case .constant(let value):
            return value
        case .variable(let name):
            return variables[name] ?? 0
        case .binary(let op, let lhs, let rhs):
            let l = evaluate(lhs)
            let r = evaluate(rhs)
            switch op {
            case .plus: return l + r
            case .minus: return l - r
            case .multiply: return l * r
            case .divide: return r != 0 ? l / r : 0
            case .modulo: return r != 0 ? l % r : 0
            }
        }
    }

    private func evaluate(_ condition: Condition) -> Bool {
        switch condition {
        case .comparison(let lhs, let op, let rhs):
            let l = evaluate(lhs)
            let r = evaluate(rhs)
            switch op {
            case .equal: return l == r
            case .notEqual: return l != r
            case .greater: return l > r
            case .less: return l < r
            case .greaterOrEqual: return l >= r
            case .lessOrEqual: return l <= r
            }
        }
    }
}
