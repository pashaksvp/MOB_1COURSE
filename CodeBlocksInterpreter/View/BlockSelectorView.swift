import SwiftUI

struct BlockSelectorView: View {
    @ObservedObject var block: BlockViewModel
    @State private var isDragging = false
    @State private var showDeleteButton = false
    
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemBackground))
                    .shadow(radius: isDragging ? 4 : 0)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(borderColor, lineWidth: 1)
            )
            .scaleEffect(isDragging ? 1.02 : 1.0)
            .animation(.spring(), value: isDragging)
            .contextMenu {
                Button(role: .destructive) {
                    block.onDelete?()
                } label: {
                    Label("Удалить", systemImage: "trash")
                }
            }
            .onLongPressGesture {
                showDeleteButton = true
            }
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
        .padding(12)
    }
    
    private var deleteButton: some View {
        Group {
            if showDeleteButton {
                Button {
                    block.onDelete?()
                    showDeleteButton = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .background(Color.white.clipShape(Circle()))
                }
                .offset(x: 8, y: -8)
                .onTapGesture {
                    showDeleteButton = false
                }
            }
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
