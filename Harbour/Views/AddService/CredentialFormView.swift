import SwiftUI

/// Credential entry, shape depends on `ServiceType.credentialKind`. On submit,
/// the secret goes to the Keychain and a `ServiceDefinition` is persisted —
/// never the other way around.
struct CredentialFormView: View {
    let type: ServiceType
    let baseURL: URL
    var onSave: () -> Void

    @Environment(ServiceRegistry.self) private var registry
    @State private var displayName: String = ""
    @State private var primaryField: String = ""
    @State private var secondaryField: String = ""

    var body: some View {
        Form {
            Section("Name") {
                TextField(type.displayName, text: $displayName)
            }

            Section(credentialSectionTitle) {
                switch type.credentialKind {
                case .usernamePassword:
                    TextField("Username", text: $primaryField)
                        .textInputAutocapitalization(.never)
                    SecureField("Password", text: $secondaryField)
                case .apiKey, .longLivedToken, .token, .personalAccessToken:
                    SecureField(credentialFieldLabel, text: $primaryField)
                }
            }

            Section {
                Button("Save") { save() }
                    .disabled(!isValid)
            }
        }
        .navigationTitle("Connect")
        .onAppear {
            if displayName.isEmpty { displayName = type.displayName }
        }
    }

    private var credentialSectionTitle: String {
        switch type.credentialKind {
        case .usernamePassword: return "Login"
        default: return "Credential"
        }
    }

    private var credentialFieldLabel: String {
        switch type.credentialKind {
        case .apiKey: return "API Key"
        case .longLivedToken: return "Long-Lived Access Token"
        case .token: return "Plex Token"
        case .personalAccessToken: return "Personal Access Token"
        case .usernamePassword: return ""
        }
    }

    private var isValid: Bool {
        switch type.credentialKind {
        case .usernamePassword:
            return !primaryField.isEmpty && !secondaryField.isEmpty
        default:
            return !primaryField.isEmpty
        }
    }

    private func save() {
        let credential: String
        switch type.credentialKind {
        case .usernamePassword:
            // UnifiClient (not yet implemented) splits this on the first ":".
            credential = "\(primaryField):\(secondaryField)"
        default:
            credential = primaryField
        }

        let definition = ServiceDefinition(
            type: type,
            displayName: displayName.isEmpty ? type.displayName : displayName,
            baseURL: baseURL
        )

        do {
            try KeychainManager.save(credential, for: definition.id)
            registry.add(definition)
            onSave()
        } catch {
            // Keychain write failed — don't persist a service with no usable credential.
        }
    }
}
