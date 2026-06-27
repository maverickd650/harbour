import Foundation

struct DetectedService {
    let type: ServiceType
    let baseURL: URL
    let detailLine: String?
}

/// Fires parallel probes against a candidate base URL; first 200 response that
/// matches a service's fingerprint wins.
enum ServiceDetector {
    static func detect(baseURL: URL) async -> DetectedService? {
        await withTaskGroup(of: DetectedService?.self) { group in
            for type in ServiceType.allCases {
                group.addTask {
                    await probe(type: type, baseURL: baseURL)
                }
            }

            var winner: DetectedService?
            for await result in group {
                if let result {
                    winner = result
                    break
                }
            }
            group.cancelAll()
            return winner
        }
    }

    private static func probe(type: ServiceType, baseURL: URL) async -> DetectedService? {
        guard let probeURL = URL(string: type.probePath, relativeTo: baseURL) else { return nil }

        var request = URLRequest(url: probeURL)
        request.timeoutInterval = AppConstants.probeTimeout

        let session = URLSession(configuration: .ephemeral)
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { return nil }
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
            guard type.matchesFingerprint(json) else { return nil }
            return DetectedService(type: type, baseURL: baseURL, detailLine: type.detailLine(from: json))
        } catch {
            return nil
        }
    }
}
