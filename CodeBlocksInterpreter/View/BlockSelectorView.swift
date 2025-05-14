import SwiftUI

struct BlockSelectorView: View {
    @ObservedObject var block: BlockViewModel
    @State private var isDragging = false
    
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 2)
            )
            .shadow(color: isDragging ? Color.blue.opacity(0.4) : Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .scaleEffect(isDragging ? 1.02 : 1.0)
            .animation(.spring(), value: isDragging)
            .overlay(deleteButton, alignment: .topTrailing)
    }
    
    private var content: some View {
        Group {
            switch block.type {
            case .variableDeclaration:
                VariableBlockView(viewModel: block)
            case .assignment:
                AssignmentBlockView(viewModel: block)
            case .ifStatement:
                IfBlockView(viewModel: block)
            }
        }
        .padding(16)
    }
    
    private var deleteButton: some View {
        Button {
            block.onDelete?()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(Color.white, Color.red)
                .font(.system(size: 20))
        }
        .offset(x: 8, y: -8)
        .buttonStyle(.plain)
    }
    
    private var backgroundColor: Color {
        if block.hasError {
            return Color.red.opacity(0.1)
        }
        switch block.type {
        case .variableDeclaration: return Color.blue.opacity(0.05)
        case .assignment: return Color.green.opacity(0.05)
        case .ifStatement: return Color.orange.opacity(0.05)
        }
    }
    
    private var borderColor: Color {
        if block.hasError {
            return Color.red
        }
        switch block.type {
        case .variableDeclaration: return Color.blue
        case .assignment: return Color.green
        case .ifStatement: return Color.orange
        }
    }
}
