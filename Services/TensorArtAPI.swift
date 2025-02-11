import Foundation

class TensorArtAPI {
    private let baseURL: String
    private let apiToken: String
    private let sdModel: String
    private let loraModel: String
    
    init() {
        self.baseURL = Const.TensorArt.apiEndpoint
        self.apiToken = Const.TensorArt.apiToken
        self.sdModel = Const.TensorArt.sdModel
        self.loraModel = Const.TensorArt.loraModel
    }
    
    // MARK: - Upload Image
    func uploadImage(expireSeconds: Int = 3600) async throws -> TensorArtUploadResponse {
        let url = URL(string: "\(baseURL)/v1/resource/image")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        
        let uploadRequest = TensorArtUploadRequest(expireSec: expireSeconds)
        request.httpBody = try JSONEncoder().encode(uploadRequest)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(TensorArtUploadResponse.self, from: data)
    }
    
    // MARK: - Create Job
    func createJob(imageResourceId: String, prompt: String, negativePrompt: String) async throws -> TensorArtJobResponse {
        let url = URL(string: "\(baseURL)/v1/jobs")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        
        let jobRequest = TensorArtJobRequest(
            requestId: UUID().uuidString,
            stages: [
                Stage(
                    type: "INPUT_INITIALIZE",
                    inputInitialize: InputInitialize(
                        imageResourceId: imageResourceId,
                        count: 1
                    ),
                    diffusion: nil
                ),
                Stage(
                    type: "DIFFUSION",
                    inputInitialize: nil,
                    diffusion: Diffusion(
                        width: 768,
                        height: 1024,
                        prompts: [Prompt(text: prompt)],
                        negativePrompts: [Prompt(text: negativePrompt)],
                        sdModel: sdModel,
                        sdVae: "ae.sft",
                        sampler: "euler",
                        steps: 25,
                        cfgScale: 7,
                        clipSkip: 2,
                        lora: Lora(items: [
                            LoraItem(
                                loraModel: loraModel,
                                weight: 0.8
                            )
                        ]),
                        embedding: [:],
                        scheduleName: "simple",
                        guidance: 3.5
                    )
                )
            ]
        )
        
        request.httpBody = try JSONEncoder().encode(jobRequest)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(TensorArtJobResponse.self, from: data)
    }
    
    // MARK: - Get Job Status
    func getJobStatus(jobId: String) async throws -> TensorArtJobStatus {
        let url = URL(string: "\(baseURL)/v1/jobs/\(jobId)")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(TensorArtJobStatus.self, from: data)
    }
    
    // MARK: - Upload Image Data
    func uploadImageData(_ imageData: Data, to putUrl: String, headers: [String: String]) async throws {
        var request = URLRequest(url: URL(string: putUrl)!)
        request.httpMethod = "PUT"
        
        // Add custom headers
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        request.httpBody = imageData
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "TensorArtAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to upload image"])
        }
    }
} 