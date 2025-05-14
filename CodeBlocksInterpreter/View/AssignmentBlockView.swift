import SwiftUI

struct AssignmentBlockView: View {
    @ObservedObject var viewModel: BlockViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "arrow.right.square.fill")
                    .foregroundColor(.green)
                Text("Присваивание")
                    .font(.headline)
            }
            
            TextField("Пример: a = 3 + b", text: $viewModel.text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.system(.body, design: .monospaced))
                .background(viewModel.hasError ? Color.red.opacity(0.1) : Color.clear)
                .cornerRadius(6)
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 4)
            }
        }
    }
}
