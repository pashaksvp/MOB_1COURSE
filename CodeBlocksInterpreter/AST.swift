import Foundation

indirect enum ASTNode {
    case variableDeclaration([String])
    case assignment(variable: String, expression: Expression)
    case ifStatement(condition: Condition, body: [ASTNode], elseBody: [ASTNode]?)
}

indirect enum Expression {
    case variable(String)
    case constant(Int)
    case binary(op: BinaryOp, lhs: Expression, rhs: Expression)
}

enum BinaryOp: String {
    case plus = "+"
    case minus = "-"
    case multiply = "*"
    case divide = "/"
    case modulo = "%"
}

indirect enum Condition {
    case comparison(lhs: Expression, op: ComparisonOp, rhs: Expression)
}

enum ComparisonOp: String {
    case equal = "=="
    case notEqual = "!="
    case greater = ">"
    case less = "<"
    case greaterOrEqual = ">="
    case lessOrEqual = "<="
}
