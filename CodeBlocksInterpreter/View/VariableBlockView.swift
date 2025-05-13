import SwiftUI

struct VariableBlockView: View {
    @ObservedObject var viewModel: BlockViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("Объявление переменных:")
                .font(.caption)
            TextField("Например: a, b, c", text: $viewModel.text)
                .padding(5)
                .background(viewModel.hasError ? Color.red.opacity(0.3) : Color.gray.opacity(0.1))
                .cornerRadius(5)
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(viewModel.hasError ? Color.red : Color.blue, lineWidth: 2)
        )
        .padding(.horizontal)
    }
}
