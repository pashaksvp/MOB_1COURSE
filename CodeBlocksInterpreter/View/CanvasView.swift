import SwiftUI

struct CanvasView: View {
    @StateObject var viewModel = CanvasViewModel()
    @State private var draggingItem: BlockViewModel?
    @State private var currentDropPosition: DropPosition?
    
    enum DropPosition: Equatable {
        case top(UUID)
        case bottom(UUID)
    }
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    if let error = viewModel.runtimeError {
                        ErrorBanner(message: error)
                            .transition(.opacity)
                    }
                    
                    ForEach(viewModel.blocks) { block in
                        BlockSelectorView(block: block)
                            .overlay(dropIndicator(for: block.id))
                            .onDrag {
                                draggingItem = block
                                return NSItemProvider(object: block.id.uuidString as NSString)
                            }
                            .onDrop(of: [.text], delegate: makeDropDelegate(block: block))
                            .onAppear {
                                block.onDelete = { [weak viewModel] in
                                    withAnimation {
                                        viewModel?.removeBlock(id: block.id)
                                    }
                                }
                            }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            
            HStack(spacing: 12) {
                BlockTypeButton(
                    icon: "v.square.fill",
                    color: .blue,
                    text: "Переменные",
                    action: { viewModel.addBlock(type: .variableDeclaration) }
                )
                
                BlockTypeButton(
                    icon: "arrow.right.square.fill",
                    color: .green,
                    text: "Присваивание",
                    action: { viewModel.addBlock(type: .assignment) }
                )
                
                BlockTypeButton(
                    icon: "questionmark.square.fill",
                    color: .orange,
                    text: "Условие",
                    action: { viewModel.addBlock(type: .ifStatement) }
                )
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            Button(action: {
                withAnimation {
                    viewModel.run()
                }
            }) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Выполнить")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom)
            .buttonStyle(.plain)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    
    private func dropIndicator(for blockId: UUID) -> some View {
        VStack(spacing: 0) {
            if case .top(let id) = currentDropPosition, id == blockId {
                Divider()
                    .frame(height: 2)
                    .background(Color.blue)
                    .padding(.horizontal, 16)
            }
            
            Spacer()
            
            if case .bottom(let id) = currentDropPosition, id == blockId {
                Divider()
                    .frame(height: 2)
                    .background(Color.blue)
                    .padding(.horizontal, 16)
            }
        }
    }
    
    private func makeDropDelegate(block: BlockViewModel) -> DropDelegate {
        BlockDropDelegate(
            block: block,
            blocks: $viewModel.blocks,
            draggingItem: $draggingItem,
            currentDropPosition: $currentDropPosition
        )
    }
}


struct ErrorBanner: View {
    let message: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.yellow)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding()
        .background(Color.red)
        .cornerRadius(8)
        .padding(.horizontal)
        .shadow(radius: 2)
    }
}

struct BlockTypeButton: View {
    let icon: String
    let color: Color
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Text(text)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(8)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}


struct BlockDropDelegate: DropDelegate {
    let block: BlockViewModel
    @Binding var blocks: [BlockViewModel]
    @Binding var draggingItem: BlockViewModel?
    @Binding var currentDropPosition: CanvasView.DropPosition?
    
    func dropEntered(info: DropInfo) {
        guard let draggingItem = draggingItem,
              draggingItem.id != block.id else { return }
        
        let isMovingUp = blocks.firstIndex { $0.id == block.id } ?? 0 < blocks.firstIndex { $0.id == draggingItem.id } ?? 0
        currentDropPosition = isMovingUp ? .top(block.id) : .bottom(block.id)
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        currentDropPosition = nil
        
        guard let draggingItem = draggingItem,
              let fromIndex = blocks.firstIndex(where: { $0.id == draggingItem.id }),
              let toIndex = blocks.firstIndex(where: { $0.id == block.id }) else { return false }
        
        blocks.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
        return true
    }
    
    func dropExited(info: DropInfo) {
        currentDropPosition = nil
    }
}
