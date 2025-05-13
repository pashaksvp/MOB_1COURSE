import SwiftUI

struct CanvasView: View {
    @StateObject var viewModel = CanvasViewModel()
    @State private var draggingItem: BlockViewModel?
    @State private var currentDropPosition: DropPosition?
    
    enum DropPosition : Equatable {
        case top(Int)
        case bottom(Int)
    }
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.blocks.indices, id: \.self) { index in
                        BlockSelectorView(block: viewModel.blocks[index])
                            .overlay(dropIndicator(for: index))
                            .onDrag {
                                draggingItem = viewModel.blocks[index]
                                return NSItemProvider(object: "\(index)" as NSString)
                            }
                            .onDrop(of: [.text], delegate: makeDropDelegate(index: index))
                            .onAppear {
                                viewModel.blocks[index].onDelete = { [weak viewModel] in
                                    viewModel?.removeBlock(at: index)
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
    
    private func dropIndicator(for index: Int) -> some View {
        VStack(spacing: 0) {
            if currentDropPosition == .top(index) {
                Divider()
                    .frame(height: 2)
                    .background(Color.blue)
                    .padding(.horizontal, 16)
            }
            
            Spacer()
            
            if currentDropPosition == .bottom(index) {
                Divider()
                    .frame(height: 2)
                    .background(Color.blue)
                    .padding(.horizontal, 16)
            }
        }
    }
    
    private func makeDropDelegate(index: Int) -> DropDelegate {
        return BlockDropDelegate(
            index: index,
            blocks: $viewModel.blocks,
            draggingItem: $draggingItem,
            currentDropPosition: $currentDropPosition
        )
    }
}

struct BlockDropDelegate: DropDelegate {
    let index: Int
    @Binding var blocks: [BlockViewModel]
    @Binding var draggingItem: BlockViewModel?
    @Binding var currentDropPosition: CanvasView.DropPosition?
    
    func dropEntered(info: DropInfo) {
        guard let draggingItem = draggingItem,
              let fromIndex = blocks.firstIndex(where: { $0.id == draggingItem.id }) else { return }
        
        if fromIndex != index {
            let isMovingUp = index < fromIndex
            currentDropPosition = isMovingUp ? .top(index) : .bottom(index)
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        currentDropPosition = nil
        
        guard let draggingItem = draggingItem,
              let fromIndex = blocks.firstIndex(where: { $0.id == draggingItem.id }) else { return false }
        
        let toIndex = index > fromIndex ? index : index
        blocks.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex)
        return true
    }
    
    func dropExited(info: DropInfo) {
        currentDropPosition = nil
    }
}
