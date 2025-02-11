import Foundation
import Combine

/// Protocol defining the interface for the Background Generator API
protocol BackgroundGeneratorServiceProtocol {
    /// Generate a new background from the given image and prompt
    /// - Parameters:
    ///   - image: URL of the input image
    ///   - prompt: Text description of the desired background
    /// - Returns: The generation result
    func generateBackground(image: URL, prompt: String) async throws -> BackgroundResult
    
    /// Get the status of a generation
    /// - Parameter id: The generation ID
    /// - Returns: The current state of the generation
    func getGeneration(id: String) async throws -> BackgroundResult
    
    /// Cancel an ongoing generation
    /// - Parameter id: The generation ID to cancel
    /// - Returns: True if successfully canceled
    func cancelGeneration(id: String) async throws -> Bool
    
    /// List all generations
    /// - Returns: Array of generation results
    func listGenerations() async throws -> [BackgroundResult]
    
    /// Get a publisher to track generation progress
    /// - Parameter id: The generation ID to track
    /// - Returns: A publisher emitting generation updates
    func generationPublisher(id: String) -> AnyPublisher<BackgroundResult, Error>
}

/// Implementation of the Background Generator API service
final class BackgroundGeneratorService: BackgroundGeneratorServiceProtocol {
    private let baseURL = "https://api.replicate.com/v1"
    private let apiToken: String
    private let session: URLSession
    private let modelVersion = "1fbd2b79f5cc40346dece1f1bba461c4239e012497b479ade7a493979b493ca4"
    
    init(apiToken: String = Const.Replicate.apiKey, session: URLSession = .shared) {
        self.apiToken = apiToken
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 180
        config.timeoutIntervalForResource = 180
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - API Methods
    
    func generateBackground(image: URL, prompt: String) async throws -> BackgroundResult {
        let endpoint = "\(baseURL)/predictions"
        
        // 准备请求数据
        let input = BackgroundInput.defaultInput(
            image: image.absoluteString,
            prompt: prompt
        )
        
        let request = BackgroundRequest(
            version: modelVersion,
            input: input
        )
        
        // 创建请求
        var urlRequest = try createRequest(for: endpoint, method: "POST")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        // 发送请求
        let (data, response) = try await session.data(for: urlRequest)
        
        // 验证响应
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BackgroundGeneratorError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            let result = try JSONDecoder().decode(BackgroundResult.self, from: data)
            return result
        case 401:
            throw BackgroundGeneratorError.authenticationFailed
        default:
            throw BackgroundGeneratorError.requestFailed("Status code: \(httpResponse.statusCode)")
        }
    }
    
    func getGeneration(id: String) async throws -> BackgroundResult {
        let endpoint = "\(baseURL)/predictions/\(id)"
        let request = try createRequest(for: endpoint, method: "GET")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BackgroundGeneratorError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            let result = try JSONDecoder().decode(BackgroundResult.self, from: data)
            return result
        case 401:
            throw BackgroundGeneratorError.authenticationFailed
        default:
            throw BackgroundGeneratorError.requestFailed("Status code: \(httpResponse.statusCode)")
        }
    }
    
    func cancelGeneration(id: String) async throws -> Bool {
        let endpoint = "\(baseURL)/predictions/\(id)/cancel"
        let request = try createRequest(for: endpoint, method: "POST")
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BackgroundGeneratorError.invalidResponse
        }
        
        return httpResponse.statusCode == 200
    }
    
    func listGenerations() async throws -> [BackgroundResult] {
        let endpoint = "\(baseURL)/predictions"
        let request = try createRequest(for: endpoint, method: "GET")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BackgroundGeneratorError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            let results = try JSONDecoder().decode([BackgroundResult].self, from: data)
            return results
        case 401:
            throw BackgroundGeneratorError.authenticationFailed
        default:
            throw BackgroundGeneratorError.requestFailed("Status code: \(httpResponse.statusCode)")
        }
    }
    
    // MARK: - Helper Methods
    
    private func createRequest(for endpoint: String, method: String) throws -> URLRequest {
        guard let url = URL(string: endpoint) else {
            throw BackgroundGeneratorError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
    }
}

// MARK: - Progress Tracking
extension BackgroundGeneratorService {
    func generationPublisher(id: String) -> AnyPublisher<BackgroundResult, Error> {
        Timer.publish(every: 2.0, on: .main, in: .common)
            .autoconnect()
            .flatMap { [weak self] _ -> AnyPublisher<BackgroundResult, Error> in
                guard let self = self else {
                    return Fail(error: BackgroundGeneratorError.invalidData).eraseToAnyPublisher()
                }
                
                return Future { promise in
                    Task {
                        do {
                            let result = try await self.getGeneration(id: id)
                            promise(.success(result))
                        } catch {
                            promise(.failure(error))
                        }
                    }
                }
                .eraseToAnyPublisher()
            }
            .prefix(while: { result in
                result.status == .starting || result.status == .processing
            })
            .eraseToAnyPublisher()
    }
} 