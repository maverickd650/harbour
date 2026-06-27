import SwiftUI

private struct AddServiceDestination: Hashable {
    let type: ServiceType
    let baseURL: URL
}

/// Bottom sheet: URL tab with live detection, Browse tab with a manual service
/// type picker. Both end at `CredentialFormView`.
struct AddServiceSheet: View {
    private enum Tab { case url, browse }

    @Environment(\.dismiss) private var dismiss
    @State private var tab: Tab = .url

    @State private var urlText = ""
    @State private var detectionState: DetectionState = .idle
    @State private var detectionTask: Task<Void, Never>?

    @State private var browseSelection: ServiceType?
    @State private var browseURLText = ""

    @State private var destination: AddServiceDestination?

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Picker("", selection: $tab) {
                    Text("URL").tag(Tab.url)
                    Text("Browse").tag(Tab.browse)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                switch tab {
                case .url: urlTab
                case .browse: browseTab
                }

                Spacer()
            }
            .padding(.top, 8)
            .background(AppColors.background)
            .navigationTitle("Add Service")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .navigationDestination(item: $destination) { destination in
                CredentialFormView(type: destination.type, baseURL: destination.baseURL) {
                    dismiss()
                }
            }
        }
    }

    // MARK: - URL tab

    private var urlTab: some View {
        VStack(alignment: .leading, spacing: 14) {
            TextField("192.168.1.50 or truenas.local", text: $urlText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.URL)
                .padding(12)
                .background(AppColors.card)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.border, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            DetectionView(state: detectionState)

            if case .found(let detected) = detectionState {
                Button("Continue") {
                    destination = AddServiceDestination(type: detected.type, baseURL: detected.baseURL)
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("Detect") { runDetection() }
                    .buttonStyle(.borderedProminent)
                    .disabled(urlText.trimmingCharacters(in: .whitespaces).isEmpty || isProbing)
            }
        }
        .padding(.horizontal)
    }

    private var isProbing: Bool {
        if case .probing = detectionState { return true }
        return false
    }

    private func runDetection() {
        guard let baseURL = Self.normalizeURLInput(urlText) else {
            detectionState = .notFound
            return
        }
        detectionTask?.cancel()
        detectionState = .probing
        detectionTask = Task {
            let result = await ServiceDetector.detect(baseURL: baseURL)
            guard !Task.isCancelled else { return }
            detectionState = result.map(DetectionState.found) ?? .notFound
        }
    }

    static func normalizeURLInput(_ raw: String) -> URL? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let withScheme = trimmed.contains("://") ? trimmed : "http://\(trimmed)"
        return URL(string: withScheme)
    }

    // MARK: - Browse tab

    private var browseTab: some View {
        VStack(alignment: .leading, spacing: 14) {
            List(ServiceType.allCases) { type in
                HStack {
                    Image(systemName: type.systemImageName)
                        .foregroundStyle(AppColors.textSecondary)
                    Text(type.displayName)
                        .foregroundStyle(AppColors.textPrimary)
                    Spacer()
                    if browseSelection == type {
                        Image(systemName: "checkmark")
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { browseSelection = type }
                .listRowBackground(AppColors.card)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .frame(height: 260)

            if browseSelection != nil {
                TextField("192.168.1.50 or hostname", text: $browseURLText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                    .padding(12)
                    .background(AppColors.card)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.border, lineWidth: 1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Button("Continue") {
                    guard let type = browseSelection, let url = Self.normalizeURLInput(browseURLText) else { return }
                    destination = AddServiceDestination(type: type, baseURL: url)
                }
                .buttonStyle(.borderedProminent)
                .disabled(Self.normalizeURLInput(browseURLText) == nil)
            }
        }
        .padding(.horizontal)
    }
}
