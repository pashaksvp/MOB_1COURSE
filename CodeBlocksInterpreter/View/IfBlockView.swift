import SwiftUI

struct IfBlockView: View {
    @ObservedObject var viewModel: BlockViewModel
    @State private var draggingChild: BlockViewModel?
    @State private var dropPosition: DropPosition?
    
    enum DropPosition: Equatable {
        case top(UUID)
        case bottom(UUID)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            childrenList
            addButton
        }
        .background(Color.orange.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: 2)
        )
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "questionmark.square.fill")
                    .foregroundColor(.orange)
                Text("Условие if")
                    .font(.headline)
            }
            
            TextField("Пример: a > 5", text: $viewModel.text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.system(.body, design: .monospaced))
                .background(viewModel.hasError ? Color.red.opacity(0.1) : Color.clear)
                .cornerRadius(6)
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
            }
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
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
        }
    }
    
    private var addButton: some View {
        Button(action: addChild) {
            Label("Добавить блок", systemImage: "plus")
                .font(.subheadline)
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
        }
        .buttonStyle(.plain)
    }
    
    private var deleteButton: some View {
        Button {
            viewModel.onDelete?()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(Color.white, Color.red)
                .font(.system(size: 20))
        }
        .offset(x: 8, y: -8)
        .buttonStyle(.plain)
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
        let newBlock = BlockViewModel(type: .assignment)
        newBlock.onDelete = { [weak viewModel] in
            viewModel?.children.removeAll { $0.id == newBlock.id }
        }
        viewModel.children.append(newBlock)
    }
    
    private var borderColor: Color {
        viewModel.hasError ? Color.red : Color.orange
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
