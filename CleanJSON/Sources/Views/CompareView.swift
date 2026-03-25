import SwiftUI

struct CompareView: View {
    @ObservedObject var viewModel: CompareViewModel

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Compare JSON Files")
                    .font(.headline)

                Spacer()

                Button(action: viewModel.compare) {
                    Label("Compare", systemImage: "arrow.left.and.right")
                }
                .disabled(!viewModel.leftDocument.isValid || !viewModel.rightDocument.isValid)

                Button(action: viewModel.clear) {
                    Label("Clear", systemImage: "trash")
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            if viewModel.showingDiff && !viewModel.diffs.isEmpty {
                diffView
            } else {
                editorView
            }
        }
    }

    var editorView: some View {
        HSplitView {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Left JSON")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Spacer()

                    Button(action: viewModel.openLeftFile) {
                        Label("Open", systemImage: "folder")
                    }
                    .buttonStyle(.plain)

                    if viewModel.leftDocument.isValid {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else if let error = viewModel.leftDocument.errorMessage {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .help(error)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

                TextEditor(text: $viewModel.leftJSON)
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 8)
                    .onChange(of: viewModel.leftJSON) { _ in
                        viewModel.validateLeft()
                    }
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Right JSON")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Spacer()

                    Button(action: viewModel.openRightFile) {
                        Label("Open", systemImage: "folder")
                    }
                    .buttonStyle(.plain)

                    if viewModel.rightDocument.isValid {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else if let error = viewModel.rightDocument.errorMessage {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .help(error)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

                TextEditor(text: $viewModel.rightJSON)
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 8)
                    .onChange(of: viewModel.rightJSON) { _ in
                        viewModel.validateRight()
                    }
            }
        }
    }

    var diffView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Differences Found: \(viewModel.diffs.count)")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()

                Button(action: {
                    viewModel.showingDiff = false
                }) {
                    Label("Back to Editor", systemImage: "arrow.left")
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            List(viewModel.diffs) { diff in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(diff.path)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.blue)

                        Spacer()

                        diffBadge(for: diff.type)
                    }

                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Left")
                                .font(.caption2)
                                .foregroundColor(.secondary)

                            Text(diff.leftValue ?? "—")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(diff.type == .removed || diff.type == .modified ? .red : .primary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Right")
                                .font(.caption2)
                                .foregroundColor(.secondary)

                            Text(diff.rightValue ?? "—")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(diff.type == .added || diff.type == .modified ? .green : .primary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    @ViewBuilder
    func diffBadge(for type: JSONDiff.DiffType) -> some View {
        switch type {
        case .added:
            Text("ADDED")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.green)
                .cornerRadius(4)
        case .removed:
            Text("REMOVED")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.red)
                .cornerRadius(4)
        case .modified:
            Text("MODIFIED")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.orange)
                .cornerRadius(4)
        case .equal:
            Text("EQUAL")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.gray)
                .cornerRadius(4)
        }
    }
}
