import Foundation
import SwiftUI

class BlockViewModel: ObservableObject, Identifiable {
    let id = UUID()
    @Published var text: String = ""
    @Published var hasError: Bool = false
    @Published var errorMessage: String?
    @Published var children: [BlockViewModel] = []
    var onDelete: (() -> Void)?
    
    enum BlockType {
        case variableDeclaration
        case assignment
        case ifStatement
    }
    
    var type: BlockType
    
    init(type: BlockType) {
        self.type = type
    }
    
    func toASTNode() -> ASTNode? {
        hasError = false
        errorMessage = nil
        
        switch type {
        case .variableDeclaration:
            let names = text
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
            
            if names.isEmpty {
                setError("Укажите хотя бы одну переменную")
                return nil
            }
            
            return .variableDeclaration(names)
            
        case .assignment:
            let parts = text.split(separator: "=")
            guard parts.count == 2 else {
                setError("Ожидается присваивание вида a = выражение")
                return nil
            }
            
            let lhs = parts[0].trimmingCharacters(in: .whitespaces)
            let rhs = parts[1].trimmingCharacters(in: .whitespaces)
            
            guard !lhs.isEmpty else {
                setError("Левая часть пустая")
                return nil
            }
            
            if let expr = ExpressionParser.parse(rhs) {
                return .assignment(variable: lhs, expression: expr)
            } else {
                setError("Ошибка в выражении")
                return nil
            }
            
        case .ifStatement:
            let condition = text
            if let cond = ConditionParser.parse(condition) {
                let bodyAST = children.compactMap { $0.toASTNode() }
                return .ifStatement(condition: cond, body: bodyAST)
            } else {
                setError("Ошибка в условии")
                return nil
            }
        }
    }
    
    func setRuntimeError(_ message: String) {
        DispatchQueue.main.async {
            self.hasError = true
            self.errorMessage = message
        }
    }
    
    private func setError(_ message: String) {
        hasError = true
        errorMessage = message
    }
}
