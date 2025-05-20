import Foundation

class Interpreter {
    var variables: [String: Int] = [:]
    var errors: [(message: String, blockId: UUID)] = []

    func run(nodes: [ASTNode]) {
        errors.removeAll()
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
        case .ifStatement(let condition, let body, let elseBody):
            if evaluate(condition) {
                run(nodes: body)
            } else if let elseBody = elseBody {
                run(nodes: elseBody)
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
            case .divide:
                if r == 0 {
                    if case let .binary(_, _, .variable(rhsVar)) = rhs {
                        errors.append(("Деление на ноль: переменная \(rhsVar) равна нулю", UUID()))
                    } else {
                        errors.append(("Деление на ноль в выражении", UUID()))
                    }
                    return 0
                }
                return l / r
            case .modulo:
                if r == 0 {
                    errors.append(("Остаток от деления на ноль", UUID()))
                    return 0
                }
                return l % r
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
