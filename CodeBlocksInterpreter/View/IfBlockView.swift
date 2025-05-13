import SwiftUI

struct IfBlockView: View {
    @ObservedObject var viewModel: BlockViewModel
    @State private var draggingChild: BlockViewModel?
    @State private var dropPosition: DropPosition?
    
    enum DropPosition : Equatable {
        case top(Int)
        case bottom(Int)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            childrenList
            addButton
        }
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: 2)
        )
        .padding(.horizontal)
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Условие if:")
                .font(.caption)
                .foregroundColor(.secondary)
            TextField("Пример: a > 5", text: $viewModel.text)
                .textFieldStyle(.roundedBorder)
                .background(viewModel.hasError ? Color.red.opacity(0.2) : Color.clear)
        }
        .padding()
    }
    
    private var childrenList: some View {
        ForEach(viewModel.children.indices, id: \.self) { index in
            BlockSelectorView(block: viewModel.children[index])
                .overlay(dropIndicator(for: index))
                .onDrag {
                    draggingChild = viewModel.children[index]
                    return NSItemProvider(object: "\(index)" as NSString)
                }
                .onDrop(of: [.text], delegate: makeDropDelegate(index: index))
                .onAppear {
                    viewModel.children[index].onDelete = { [weak viewModel] in
                        viewModel?.children.remove(at: index)
                    }
                }
        }
    }
    
    private var addButton: some View {
        Button(action: addChild) {
            Label("Добавить блок внутрь if", systemImage: "plus")
                .font(.caption)
        }
        .padding()
    }
    
    private func dropIndicator(for index: Int) -> some View {
        VStack(spacing: 0) {
            if dropPosition == .top(index) {
                Divider()
                    .frame(height: 2)
                    .background(Color.blue)
                    .padding(.horizontal, 16)
            }
            
            Spacer()
            
            if dropPosition == .bottom(index) {
                Divider()
                    .frame(height: 2)
                    .background(Color.blue)
                    .padding(.horizontal, 16)
            }
        }
    }
    
    private func makeDropDelegate(index: Int) -> DropDelegate {
        ChildDropDelegate(
            parent: viewModel,
            index: index,
            draggingChild: $draggingChild,
            dropPosition: $dropPosition
        )
    }
    
    private func addChild() {
        let new = BlockViewModel(type: .assignment)
        new.onDelete = { [weak viewModel] in
            if let index = viewModel?.children.firstIndex(where: { $0.id == new.id }) {
                viewModel?.children.remove(at: index)
            }
        }
        viewModel.children.append(new)
    }
    
    private var borderColor: Color {
        viewModel.hasError ? Color.red : Color.blue
    }
}

struct ChildDropDelegate: DropDelegate {
    let parent: BlockViewModel
    let index: Int
    @Binding var draggingChild: BlockViewModel?
    @Binding var dropPosition: IfBlockView.DropPosition?
    
    func dropEntered(info: DropInfo) {
        guard let draggingChild = draggingChild,
              let fromIndex = parent.children.firstIndex(where: { $0.id == draggingChild.id }) else { return }
        
        if fromIndex != index {
            let isMovingUp = index < fromIndex
            dropPosition = isMovingUp ? .top(index) : .bottom(index)
        }
    }
    
    func performDrop(info: DropInfo) -> Bool {
        dropPosition = nil
        
        guard let draggingChild = draggingChild,
              let fromIndex = parent.children.firstIndex(where: { $0.id == draggingChild.id }) else { return false }
        
        let toIndex = index > fromIndex ? index : index
        parent.children.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex)
        return true
    }
    
    func dropExited(info: DropInfo) {
        dropPosition = nil
    }
}
