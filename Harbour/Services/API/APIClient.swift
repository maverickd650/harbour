import Foundation

/// Base for all per-service API clients. Hard rule: don't use `URLSession.shared`
/// directly — every service gets its own client with auth injected per request.
class APIClient {
    let baseURL: URL
    let session: URLSession

    init(baseURL: URL, session: URLSession = APIClient.makeSession()) {
        self.baseURL = baseURL
        self.session = session
    }

    static func makeSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 8
        config.timeoutIntervalForResource = 12
        return URLSession(configuration: config)
    }

    /// Override in subclasses to inject the service's auth header/param.
    func authorize(_ request: inout URLRequest) {}

    func request(path: String, method: String = "GET", queryItems: [URLQueryItem] = []) throws -> URLRequest {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }
        if !queryItems.isEmpty {
            components.queryItems = (components.queryItems ?? []) + queryItems
        }
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        authorize(&request)
        return request
    }

    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            throw APIError.httpStatus(http.statusCode)
        }
        return (data, http)
    }

    func get<T: Decodable>(_ path: String, queryItems: [URLQueryItem] = [], as type: T.Type, decoder: JSONDecoder = .init()) async throws -> T {
        let urlRequest = try request(path: path, queryItems: queryItems)
        let (data, _) = try await send(urlRequest)
        return try decoder.decode(T.self, from: data)
    }

    func getJSONObject(_ path: String, queryItems: [URLQueryItem] = []) async throws -> [String: Any] {
        let urlRequest = try request(path: path, queryItems: queryItems)
        let (data, _) = try await send(urlRequest)
        guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw APIError.invalidResponse
        }
        return object
    }
}

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case unauthorized
}
