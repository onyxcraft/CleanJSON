import SwiftUI

struct ContentView: View {
    @EnvironmentObject var settings: AppSettings
    @StateObject private var viewModel: MainViewModel
    @StateObject private var treeViewModel = TreeViewModel()
    @StateObject private var compareViewModel = CompareViewModel()
    @State private var selectedTab = 0

    init() {
        let settings = AppSettings()
        _viewModel = StateObject(wrappedValue: MainViewModel(settings: settings))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Picker("View", selection: $selectedTab) {
                    Text("Editor").tag(0)
                    Text("Tree View").tag(1)
                    Text("Compare").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()

                TabView(selection: $selectedTab) {
                    editorView
                        .tag(0)

                    TreeView(viewModel: treeViewModel, jsonViewModel: viewModel)
                        .tag(1)

                    CompareView(viewModel: compareViewModel)
                        .tag(2)
                }
                .tabViewStyle(.automatic)
            }
        }
        .frame(minWidth: 800, minHeight: 600)
        .onChange(of: viewModel.document.parsedJSON) { newValue in
            treeViewModel.buildTree(from: newValue)
        }
    }

    var editorView: some View {
        VStack(spacing: 0) {
            toolbarView

            Divider()

            HSplitView {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("JSON Editor")
                            .font(.headline)

                        Spacer()

                        if viewModel.document.isValid {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Valid JSON")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        } else if let error = viewModel.document.errorMessage {
                            HStack(spacing: 4) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    TextEditor(text: $viewModel.formattedText)
                        .font(.system(.body, design: .monospaced))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 8)
                        .onChange(of: viewModel.formattedText) { newValue in
                            viewModel.document.rawText = newValue
                        }
                }
                .frame(minWidth: 400)

                if viewModel.showingYAML {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("YAML Preview")
                                .font(.headline)

                            Spacer()

                            Button(action: {
                                viewModel.copyToClipboard(viewModel.yamlPreview)
                            }) {
                                Label("Copy YAML", systemImage: "doc.on.doc")
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)

                        TextEditor(text: .constant(viewModel.yamlPreview))
                            .font(.system(.body, design: .monospaced))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.horizontal, 8)
                    }
                    .frame(minWidth: 300)
                }

                if !viewModel.searchResults.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Search Results")
                                .font(.headline)

                            Spacer()

                            Text("\(viewModel.searchResults.count) \(viewModel.searchResults.count == 1 ? "result" : "results")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)

                        List(viewModel.searchResults) { result in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(result.path)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.blue)

                                if let key = result.key {
                                    Text("\(key): \(result.value)")
                                        .font(.system(.caption, design: .monospaced))
                                } else {
                                    Text(result.value)
                                        .font(.system(.caption, design: .monospaced))
                                }
                            }
                            .padding(.vertical, 2)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(minWidth: 250)
                }
            }
        }
    }

    var toolbarView: some View {
        HStack {
            Button(action: viewModel.openFile) {
                Label("Open", systemImage: "folder")
            }

            Button(action: viewModel.pasteFromClipboard) {
                Label("Paste", systemImage: "doc.on.clipboard")
            }

            Divider()
                .frame(height: 20)

            Button(action: {
                viewModel.validateAndFormat()
            }) {
                Label("Format", systemImage: "text.alignleft")
            }
            .disabled(viewModel.formattedText.isEmpty)

            Button(action: viewModel.minifyJSON) {
                Label("Minify", systemImage: "arrow.down.right.and.arrow.up.left")
            }
            .disabled(!viewModel.document.isValid)

            Divider()
                .frame(height: 20)

            Button(action: {
                viewModel.copyToClipboard(viewModel.formattedText)
            }) {
                Label("Copy", systemImage: "doc.on.doc")
            }
            .disabled(viewModel.formattedText.isEmpty)

            Button(action: viewModel.saveFile) {
                Label("Save", systemImage: "square.and.arrow.down")
            }
            .disabled(viewModel.formattedText.isEmpty)

            Divider()
                .frame(height: 20)

            HStack(spacing: 4) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                TextField("Search JSON", text: $viewModel.searchQuery)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200)
                    .onSubmit {
                        viewModel.search()
                    }

                if !viewModel.searchQuery.isEmpty {
                    Button(action: viewModel.clearSearch) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }

                Button(action: viewModel.search) {
                    Text("Search")
                }
                .disabled(viewModel.searchQuery.isEmpty)
            }

            Spacer()

            Toggle(isOn: $viewModel.showingYAML) {
                Label("YAML", systemImage: "doc.text")
            }
            .toggleStyle(.button)
            .onChange(of: viewModel.showingYAML) { _ in
                viewModel.toggleYAMLView()
            }

            Picker("Indent", selection: $settings.indentStyle) {
                ForEach(IndentStyle.allCases) { style in
                    Text(style.rawValue).tag(style)
                }
            }
            .frame(width: 120)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
}
