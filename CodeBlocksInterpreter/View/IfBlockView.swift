import SwiftUI

struct IfBlockView: View {
    @ObservedObject var viewModel: BlockViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Условие if:")
                .font(.caption)
            TextField("Пример: a > 5", text: $viewModel.text)
                .padding(5)
                .background(viewModel.hasError ? Color.red.opacity(0.3) : Color.gray.opacity(0.1))
                .cornerRadius(5)

            Text("Блок команд внутри if:")
                .font(.caption)
                .foregroundColor(.gray)

            ForEach(viewModel.children) { child in
                BlockSelectorView(block: child)
            }

            Button("Добавить блок внутрь if") {
                let new = BlockViewModel(type: .assignment)
                viewModel.children.append(new)
            }
            .font(.caption)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(viewModel.hasError ? Color.red : Color.blue, lineWidth: 2)
        )
        .padding(.horizontal)
    }
}
