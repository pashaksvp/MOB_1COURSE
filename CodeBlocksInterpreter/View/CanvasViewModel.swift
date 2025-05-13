import Foundation

class CanvasViewModel: ObservableObject {
    @Published var blocks: [BlockViewModel] = []

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
        let interpreter = Interpreter()
        var ast: [ASTNode] = []

        for block in blocks {
            block.hasError = false
            block.errorMessage = nil

            if let node = block.toASTNode() {
                ast.append(node)
            }
        }

        interpreter.run(nodes: ast)
        print("Переменные после выполнения: \(interpreter.variables)")
    }
}
