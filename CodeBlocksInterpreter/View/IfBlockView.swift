import SwiftUI

struct IfBlockView: View {
    @ObservedObject var viewModel: BlockViewModel
    @State private var draggingChild: BlockViewModel?
    @State private var dropPosition: DropPosition?
    
    enum DropPosition : Equatable {
        case top(UUID)
        case bottom(UUID)
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
        ForEach(viewModel.children) { child in
            BlockSelectorView(block: child)
                .overlay(dropIndicator(for: child.id))
                .onDrag {
                    draggingChild = child
                    return NSItemProvider(object: child.id.uuidString as NSString)
                }
                .onDrop(of: [.text], delegate: makeDropDelegate(child: child))
                .onAppear {
                    child.onDelete = { [weak viewModel] in
                        viewModel?.children.removeAll { $0.id == child.id }
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
    
    private func dropIndicator(for childId: UUID) -> some View {
        VStack(spacing: 0) {
            if case .top(let id) = dropPosition, id == childId {
                Divider()
                    .frame(height: 2)
                    .background(Color.blue)
                    .padding(.horizontal, 16)
            }
            
            Spacer()
            
            if case .bottom(let id) = dropPosition, id == childId {
                Divider()
                    .frame(height: 2)
                    .background(Color.blue)
                    .padding(.horizontal, 16)
            }
        }
    }
    
    private func makeDropDelegate(child: BlockViewModel) -> DropDelegate {
        ChildDropDelegate(
            parent: viewModel,
            child: child,
            draggingChild: $draggingChild,
            dropPosition: $dropPosition
        )
    }
    
    private func addChild() {
        let new = BlockViewModel(type: .assignment)
        new.onDelete = { [weak viewModel] in
            viewModel?.children.removeAll { $0.id == new.id }
        }
        viewModel.children.append(new)
    }
    
    private var borderColor: Color {
        viewModel.hasError ? Color.red : Color.blue
    }
}

struct ChildDropDelegate: DropDelegate {
    let parent: BlockViewModel
    let child: BlockViewModel
    @Binding var draggingChild: BlockViewModel?
    @Binding var dropPosition: IfBlockView.DropPosition?
    
    func dropEntered(info: DropInfo) {
        guard let draggingChild = draggingChild,
              draggingChild.id != child.id else { return }
        
        let isMovingUp = parent.children.firstIndex { $0.id == child.id } ?? 0 < parent.children.firstIndex { $0.id == draggingChild.id } ?? 0
        dropPosition = isMovingUp ? .top(child.id) : .bottom(child.id)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        dropPosition = nil
        
        guard let draggingChild = draggingChild,
              let fromIndex = parent.children.firstIndex(where: { $0.id == draggingChild.id }),
              let toIndex = parent.children.firstIndex(where: { $0.id == child.id }) else { return false }
        
        parent.children.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
        return true
    }
    
    func dropExited(info: DropInfo) {
        dropPosition = nil
    }
}
