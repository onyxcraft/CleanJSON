import SwiftUI

struct TreeView: View {
    @ObservedObject var viewModel: TreeViewModel
    @ObservedObject var jsonViewModel: MainViewModel

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("JSON Tree View")
                    .font(.headline)

                Spacer()

                Button(action: viewModel.expandAll) {
                    Label("Expand All", systemImage: "arrow.down.right.and.arrow.up.left")
                }
                .buttonStyle(.plain)

                Button(action: viewModel.collapseAll) {
                    Label("Collapse All", systemImage: "arrow.up.left.and.arrow.down.right")
                }
                .buttonStyle(.plain)

                if let selected = viewModel.selectedNode {
                    Button(action: {
                        jsonViewModel.copyToClipboard(selected.path)
                    }) {
                        Label("Copy Path", systemImage: "doc.on.doc")
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            if let root = viewModel.rootNode {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        TreeNodeView(node: root, viewModel: viewModel, level: 0)
                    }
                    .padding()
                }
            } else {
                VStack {
                    Spacer()
                    Text("No JSON loaded")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }

            if let selected = viewModel.selectedNode {
                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Selected Node")
                            .font(.headline)

                        Spacer()
                    }

                    HStack {
                        Text("Path:")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(selected.path)
                            .font(.system(.caption, design: .monospaced))
                            .textSelection(.enabled)
                    }

                    HStack {
                        Text("Type:")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(selected.typeDescription)
                            .font(.caption)
                    }

                    if let key = selected.key {
                        HStack {
                            Text("Key:")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text(key)
                                .font(.system(.caption, design: .monospaced))
                        }
                    }

                    HStack {
                        Text("Value:")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(selected.displayValue)
                            .font(.system(.caption, design: .monospaced))
                            .lineLimit(3)
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
            }
        }
    }
}

struct TreeNodeView: View {
    @ObservedObject var node: JSONNode
    @ObservedObject var viewModel: TreeViewModel
    let level: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Button(action: {
                viewModel.selectNode(node)
                if node.hasChildren {
                    viewModel.toggleNode(node)
                }
            }) {
                HStack(spacing: 4) {
                    if node.hasChildren {
                        Image(systemName: node.isExpanded ? "chevron.down" : "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 12)
                    } else {
                        Spacer()
                            .frame(width: 12)
                    }

                    if let key = node.key {
                        Text(key)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.blue)

                        Text(":")
                            .foregroundColor(.secondary)
                    }

                    Text(node.displayValue)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(valueColor(for: node))

                    Text("(\(node.typeDescription))")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()
                }
                .padding(.leading, CGFloat(level * 20))
                .padding(.vertical, 4)
                .background(viewModel.selectedNode?.id == node.id ? Color.accentColor.opacity(0.2) : Color.clear)
                .cornerRadius(4)
            }
            .buttonStyle(.plain)

            if node.isExpanded {
                ForEach(node.children, id: \.id) { child in
                    TreeNodeView(node: child, viewModel: viewModel, level: level + 1)
                }
            }
        }
    }

    func valueColor(for node: JSONNode) -> Color {
        if node.value is String {
            return .green
        } else if node.value is NSNumber {
            return .orange
        } else if node.value is NSNull {
            return .red
        }
        return .primary
    }
}
