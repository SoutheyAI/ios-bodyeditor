import Foundation

// MARK: - Upload Image Models
struct TensorArtUploadRequest: Codable {
    let expireSec: Int
}

struct TensorArtUploadResponse: Codable {
    let putUrl: String
    let headers: [String: String]
    let resourceId: String
}

// MARK: - Job Creation Models
struct TensorArtJobRequest: Codable {
    let requestId: String
    let stages: [Stage]
}

struct Stage: Codable {
    let type: String
    let inputInitialize: InputInitialize?
    let diffusion: Diffusion?
}

struct InputInitialize: Codable {
    let imageResourceId: String
    let count: Int
}

struct Diffusion: Codable {
    let width: Int
    let height: Int
    let prompts: [Prompt]
    let negativePrompts: [Prompt]
    let sdModel: String
    let sdVae: String
    let sampler: String
    let steps: Int
    let cfgScale: Int
    let clipSkip: Int
    let lora: Lora?
    let embedding: [String: String]
    let scheduleName: String
    let guidance: Double
}

struct Prompt: Codable {
    let text: String
}

struct Lora: Codable {
    let items: [LoraItem]
}

struct LoraItem: Codable {
    let loraModel: String
    let weight: Double
}

// MARK: - Job Response Models
struct TensorArtJobResponse: Codable {
    let job: JobInfo
}

struct JobInfo: Codable {
    let id: String
}

// MARK: - Job Status Models
struct TensorArtJobStatus: Codable {
    let job: JobStatusInfo
}

struct JobStatusInfo: Codable {
    let status: String
    let successInfo: SuccessInfo?
}

struct SuccessInfo: Codable {
    let images: [ImageInfo]
}

struct ImageInfo: Codable {
    let url: String
} 