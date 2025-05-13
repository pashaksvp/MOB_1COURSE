import SwiftUI

struct CanvasView: View {
    @StateObject var viewModel = CanvasViewModel()

    var body: some View {
        VStack {
            ScrollView {
                ForEach(viewModel.blocks) { block in
                    BlockSelectorView(block: block)
                }
            }

            HStack {
                Button("Добавить переменные") {
                    viewModel.addBlock(type: .variableDeclaration)
                }

                Button("Добавить присваивание") {
                    viewModel.addBlock(type: .assignment)
                }

                Button("Добавить if") {
                    viewModel.addBlock(type: .ifStatement)
                }
            }
            .padding()

            Button("Выполнить") {
                viewModel.run()
            }
            .padding()
        }
    }
}
