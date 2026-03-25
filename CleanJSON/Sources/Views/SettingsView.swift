import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        Form {
            Section {
                Picker("Default Indent Style:", selection: $settings.indentStyle) {
                    ForEach(IndentStyle.allCases) { style in
                        Text(style.rawValue).tag(style)
                    }
                }
                .pickerStyle(.radioGroup)

                Toggle("Auto-format on paste", isOn: $settings.autoFormat)

                Toggle("Validate on paste", isOn: $settings.validateOnPaste)
            } header: {
                Text("Editor Settings")
                    .font(.headline)
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("CleanJSON")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Version 1.0.0")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("A powerful JSON formatter, validator, and viewer for macOS.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)

                    Text("Copyright © 2026 LopoDragon. All rights reserved.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                .padding(.vertical, 8)
            } header: {
                Text("About")
                    .font(.headline)
            }
        }
        .formStyle(.grouped)
        .frame(width: 500, height: 400)
        .padding()
    }
}
