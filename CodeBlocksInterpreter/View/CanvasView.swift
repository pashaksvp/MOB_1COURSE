import SwiftUI

struct CanvasView: View {
    @StateObject var viewModel = CanvasViewModel()
    @State private var draggingItem: BlockViewModel?
    @State private var currentDropPosition: DropPosition?
    
    enum DropPosition : Equatable {
        case top(UUID)
        case bottom(UUID)
    }
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(spacing: 8) {
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
                                    viewModel?.removeBlock(id: block.id)
                                }
                            }
                    }
                }
                .padding(.horizontal)
            }
            
            HStack(spacing: 16) {
                Button(action: { viewModel.addBlock(type: .variableDeclaration) }) {
                    Label("Переменные", systemImage: "v.square")
                }
                
                Button(action: { viewModel.addBlock(type: .assignment) }) {
                    Label("Присваивание", systemImage: "arrow.right.square")
                }
                
                Button(action: { viewModel.addBlock(type: .ifStatement) }) {
                    Label("Условие", systemImage: "questionmark.square")
                }
            }
            .buttonStyle(.bordered)
            .padding()
            
            Button("Выполнить", action: viewModel.run)
                .buttonStyle(.borderedProminent)
                .padding(.bottom)
        }
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
        return BlockDropDelegate(
            block: block,
            blocks: $viewModel.blocks,
            draggingItem: $draggingItem,
            currentDropPosition: $currentDropPosition
        )
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
