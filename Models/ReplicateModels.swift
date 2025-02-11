import Foundation

// MARK: - Request Models
struct ReplicateRequest: Codable {
    let version: String
    let input: BackgroundGeneratorInput
}

struct BackgroundGeneratorInput: Codable {
    let image: String
    let steps: Int
    let prompt: String
    let batchCount: Int
    let cfgScale: Int
    let maxWidth: Int
    let maxHeight: Int
    let scheduler: String
    let samplerName: String
    let negativePrompt: String?
    let denoisingStrength: Float
    
    enum CodingKeys: String, CodingKey {
        case image
        case steps
        case prompt
        case batchCount = "batch_count"
        case cfgScale = "cfg_scale"
        case maxWidth = "max_width"
        case maxHeight = "max_height"
        case scheduler
        case samplerName = "sampler_name"
        case negativePrompt = "negative_prompt"
        case denoisingStrength = "denoising_strength"
    }
    
    static func defaultInput(image: String, prompt: String) -> BackgroundGeneratorInput {
        return BackgroundGeneratorInput(
            image: image,
            steps: 20,
            prompt: prompt,
            batchCount: 1,
            cfgScale: 7,
            maxWidth: 1024,
            maxHeight: 1024,
            scheduler: "Karras",
            samplerName: "DPM++ 2M SDE",
            negativePrompt: nil,
            denoisingStrength: 0.75
        )
    }
}

// MARK: - Response Models
struct ReplicatePrediction: Codable {
    let id: String
    let version: String
    let status: PredictionStatus
    let input: BackgroundGeneratorInput
    let output: [String]?
    let error: String?
    let logs: String?
    let createdAt: String
    let startedAt: String?
    let completedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, version, status, input, output, error, logs
        case createdAt = "created_at"
        case startedAt = "started_at"
        case completedAt = "completed_at"
    }
}

enum PredictionStatus: String, Codable {
    case starting
    case processing
    case succeeded
    case failed
    case canceled
}

// MARK: - Error Handling
enum ReplicateError: LocalizedError {
    case invalidURL
    case invalidResponse
    case authenticationFailed
    case requestFailed(String)
    case predictionFailed(String)
    case invalidData
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .authenticationFailed:
            return "Authentication failed"
        case .requestFailed(let message):
            return "Request failed: \(message)"
        case .predictionFailed(let message):
            return "Prediction failed: \(message)"
        case .invalidData:
            return "Invalid data received"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
} 