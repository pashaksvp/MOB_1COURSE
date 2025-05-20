import SwiftUI

struct IfBlockView: View {
    @ObservedObject var viewModel: BlockViewModel
    @State private var draggingChild: BlockViewModel?
    @State private var dropPosition: DropPosition?
    @State private var showElseSection = false
    
    enum DropPosition: Equatable {
        case top(UUID)
        case bottom(UUID)
        case elseTop(UUID)
        case elseBottom(UUID)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            childrenList
            addButton
            
            if showElseSection {
                Divider()
                    .padding(.horizontal, 16)
                
                Text("Else")
                    .font(.subheadline)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                
                elseChildrenList
                addElseButton
            } else {
                Button(action: { showElseSection = true }) {
                    Label("Добавить Else", systemImage: "plus")
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
                .overlay(dropIndicator(for: child.id, isElse: false))
                .onDrag {
                    draggingChild = child
                    return NSItemProvider(object: child.id.uuidString as NSString)
                }
                .onDrop(of: [.text], delegate: makeDropDelegate(child: child, isElse: false))
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
        }
    }
    
    private var elseChildrenList: some View {
        ForEach(viewModel.elseChildren) { child in
            BlockSelectorView(block: child)
                .overlay(dropIndicator(for: child.id, isElse: true))
                .onDrag {
                    draggingChild = child
                    return NSItemProvider(object: child.id.uuidString as NSString)
                }
                .onDrop(of: [.text], delegate: makeDropDelegate(child: child, isElse: true))
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
        }
    }
    
    private var addButton: some View {
        Button(action: { addChild(isElse: false) }) {
            Label("Добавить блок в If", systemImage: "plus")
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
    
    private var addElseButton: some View {
        Button(action: { addChild(isElse: true) }) {
            Label("Добавить блок в Else", systemImage: "plus")
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
    
    private func dropIndicator(for childId: UUID, isElse: Bool) -> some View {
        VStack(spacing: 0) {
            if case .top(let id) = dropPosition, id == childId, !isElse {
                Divider()
                    .frame(height: 2)
                    .background(Color.blue)
                    .padding(.horizontal, 16)
            } else if case .elseTop(let id) = dropPosition, id == childId, isElse {
                Divider()
                    .frame(height: 2)
                    .background(Color.blue)
                    .padding(.horizontal, 16)
            }
            
            Spacer()
            
            if case .bottom(let id) = dropPosition, id == childId, !isElse {
                Divider()
                    .frame(height: 2)
                    .background(Color.blue)
                    .padding(.horizontal, 16)
            } else if case .elseBottom(let id) = dropPosition, id == childId, isElse {
                Divider()
                    .frame(height: 2)
                    .background(Color.blue)
                    .padding(.horizontal, 16)
            }
        }
    }
    
    private func makeDropDelegate(child: BlockViewModel, isElse: Bool) -> DropDelegate {
        ChildDropDelegate(
            parent: viewModel,
            child: child,
            draggingChild: $draggingChild,
            dropPosition: $dropPosition,
            isElse: isElse
        )
    }
    
    private func addChild(isElse: Bool) {
        let newBlock = BlockViewModel(type: .assignment)
        newBlock.onDelete = { [weak viewModel] in
            if isElse {
                viewModel?.elseChildren.removeAll { $0.id == newBlock.id }
            } else {
                viewModel?.children.removeAll { $0.id == newBlock.id }
            }
        }
        
        if isElse {
            viewModel.elseChildren.append(newBlock)
        } else {
            viewModel.children.append(newBlock)
        }
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
    let isElse: Bool
    
    func dropEntered(info: DropInfo) {
        guard let draggingChild = draggingChild,
              draggingChild.id != child.id else { return }
        
        let childrenList = isElse ? parent.elseChildren : parent.children
        let isMovingUp = childrenList.firstIndex { $0.id == child.id } ?? 0 < childrenList.firstIndex { $0.id == draggingChild.id } ?? 0
        
        if isElse {
            dropPosition = isMovingUp ? .elseTop(child.id) : .elseBottom(child.id)
        } else {
            dropPosition = isMovingUp ? .top(child.id) : .bottom(child.id)
        }
    }
    
    func performDrop(info: DropInfo) -> Bool {
        defer { dropPosition = nil }
        
        guard let draggingChild = draggingChild else { return false }
        
        if isElse {
            guard let fromIndex = parent.elseChildren.firstIndex(where: { $0.id == draggingChild.id }),
                  let toIndex = parent.elseChildren.firstIndex(where: { $0.id == child.id }) else { return false }
            
            parent.elseChildren.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
        } else {
            guard let fromIndex = parent.children.firstIndex(where: { $0.id == draggingChild.id }),
                  let toIndex = parent.children.firstIndex(where: { $0.id == child.id }) else { return false }
            
            parent.children.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
        }
        
        return true
    }
    
    func dropExited(info: DropInfo) {
        dropPosition = nil
    }
}
