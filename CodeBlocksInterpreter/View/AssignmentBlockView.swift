import SwiftUI

struct AssignmentBlockView: View {
    @ObservedObject var viewModel: BlockViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Присваивание:")
                .font(.caption)
                .foregroundColor(.secondary)
            TextField("Пример: a = 3 + b", text: $viewModel.text)
                .textFieldStyle(.roundedBorder)
                .background(viewModel.hasError ? Color.red.opacity(0.2) : Color.clear)
        }
    }
}
