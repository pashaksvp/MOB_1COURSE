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
            let names = text.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            guard !names.isEmpty else {
                setError("Укажите хотя бы одну переменную")
                return nil
            }
            return .variableDeclaration(names)
            
        case .assignment:
            let parts = text.split(separator: "=").map { $0.trimmingCharacters(in: .whitespaces) }
            guard parts.count == 2, !parts[0].isEmpty else {
                setError("Некорректное присваивание")
                return nil
            }
            guard let expr = ExpressionParser.parse(parts[1]) else {
                setError("Ошибка в выражении")
                return nil
            }
            return .assignment(variable: parts[0], expression: expr)
            
        case .ifStatement:
            guard let cond = ConditionParser.parse(text) else {
                setError("Ошибка в условии")
                return nil
            }
            let body = children.compactMap { $0.toASTNode() }
            return .ifStatement(condition: cond, body: body)
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
