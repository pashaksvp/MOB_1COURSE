import SwiftUI

struct VariableBlockView: View {
    @ObservedObject var viewModel: BlockViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "v.square.fill")
                    .foregroundColor(.blue)
                Text("Объявление переменных")
                    .font(.headline)
            }
            
            TextField("Например: a, b, c", text: $viewModel.text)
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
    }
}
