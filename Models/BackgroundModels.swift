import Foundation

// MARK: - Request Models
struct BackgroundRequest: Codable {
    let version: String
    let input: BackgroundInput
}

struct BackgroundInput: Codable {
    let image: String
    let prompt: String
    let steps: Int
    let batchCount: Int
    let cfgScale: Double
    let scheduler: String?
    let negativePrompt: String?
    
    enum CodingKeys: String, CodingKey {
        case image, prompt, steps
        case batchCount = "batch_count"
        case cfgScale = "cfg_scale"
        case scheduler
        case negativePrompt = "negative_prompt"
    }
    
    static func defaultInput(image: String, prompt: String) -> BackgroundInput {
        return BackgroundInput(
            image: image,
            prompt: prompt,
            steps: 20,
            batchCount: 1,
            cfgScale: 7.0,
            scheduler: "Karras",
            negativePrompt: nil
        )
    }
}

// MARK: - Response Models
struct BackgroundResult: Codable {
    let id: String
    let version: String
    let status: GenerationStatus
    let input: BackgroundInput
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

enum GenerationStatus: String, Codable {
    case starting
    case processing
    case succeeded
    case failed
    case canceled
}

// MARK: - Error Handling
enum BackgroundGeneratorError: LocalizedError {
    case invalidURL
    case invalidResponse
    case authenticationFailed
    case requestFailed(String)
    case generationFailed(String)
    case invalidData
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的 URL"
        case .invalidResponse:
            return "服务器响应无效"
        case .authenticationFailed:
            return "认证失败，请检查 API token"
        case .requestFailed(let message):
            return "请求失败: \(message)"
        case .generationFailed(let message):
            return "生成失败: \(message)"
        case .invalidData:
            return "数据无效"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        }
    }
} 