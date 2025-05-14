import Foundation

class CanvasViewModel: ObservableObject {
    @Published var blocks: [BlockViewModel] = []
    @Published var runtimeError: String?
    
    func addBlock(type: BlockViewModel.BlockType) {
        blocks.append(BlockViewModel(type: type))
    }
    
    func moveBlock(from source: IndexSet, to destination: Int) {
        blocks.move(fromOffsets: source, toOffset: destination)
    }
    
    func removeBlock(at index: Int) {
        blocks.remove(at: index)
    }
    
    func removeBlock(id: UUID) {
        blocks.removeAll { $0.id == id }
    }
    
    func run() {
        runtimeError = nil
        let interpreter = Interpreter()
        
        for block in blocks {
            block.hasError = false
            block.errorMessage = nil
        }
        
        var ast: [ASTNode] = []
        for block in blocks {
            if let node = block.toASTNode() {
                ast.append(node)
            }
        }
        
        interpreter.run(nodes: ast)
        
        if !interpreter.errors.isEmpty {
            runtimeError = interpreter.errors.map { $0.message }.joined(separator: "\n")
            
            for block in blocks {
                if let error = interpreter.errors.first(where: { $0.blockId == block.id }) {
                    block.setRuntimeError(error.message)
                }
            }
        }
        
        print("Переменные после выполнения: \(interpreter.variables)")
    }
}
