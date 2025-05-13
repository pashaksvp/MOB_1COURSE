import SwiftUI

struct VariableBlockView: View {
    @ObservedObject var viewModel: BlockViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Объявление переменных:")
                .font(.caption)
                .foregroundColor(.secondary)
            TextField("Например: a, b, c", text: $viewModel.text)
                .textFieldStyle(.roundedBorder)
                .background(viewModel.hasError ? Color.red.opacity(0.2) : Color.clear)
        }
    }
}
