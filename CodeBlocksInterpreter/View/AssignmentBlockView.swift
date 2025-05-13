import SwiftUI

struct AssignmentBlockView: View {
    @ObservedObject var viewModel: BlockViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("Присваивание:")
                .font(.caption)
            TextField("Пример: a = 3 + b", text: $viewModel.text)
                .padding(5)
                .background(viewModel.hasError ? Color.red.opacity(0.3) : Color.gray.opacity(0.1))
                .cornerRadius(5)
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(viewModel.hasError ? Color.red : Color.green, lineWidth: 2)
        )
        .padding(.horizontal)
    }
}
