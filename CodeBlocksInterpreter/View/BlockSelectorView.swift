import SwiftUI

struct BlockSelectorView: View {
    @ObservedObject var block: BlockViewModel

    var body: some View {
        switch block.type {
        case .variableDeclaration:
            VariableBlockView(viewModel: block)
        case .assignment:
            AssignmentBlockView(viewModel: block)
        case .ifStatement:
            IfBlockView(viewModel: block)
        }
    }
}
