import UIKit
import SwiftUI
import KeychainSwift
import Combine

@MainActor
class VisionVM: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var isGenerating = false
    @Published var generationProgress: Double = 0
    @Published var currentResult: TensorArtJobStatus?
    @Published var errorMessage = ""
    @Published var isShowingError = false
    @Published var prompt: String = ""
    
    private let tensorArtAPI: TensorArtAPI
    private var currentJobId: String?
    private var statusCheckTimer: Timer?
    
    @AppStorage("freeCredits") var freeCredits: Int = 5
    
    init() {
        self.tensorArtAPI = TensorArtAPI()
    }
    
    func canGenerate() -> Bool {
        return freeCredits > 0
    }
    
    func generateBackground() async {
        guard let image = selectedImage, let imageData = image.jpegData(compressionQuality: 0.8) else {
            showError("Failed to process image")
            return
        }
        
        isGenerating = true
        generationProgress = 0.1
        
        do {
            // 1. Get upload URL
            let uploadResponse = try await tensorArtAPI.uploadImage()
            generationProgress = 0.2
            
            // 2. Upload image data
            try await tensorArtAPI.uploadImageData(imageData, to: uploadResponse.putUrl, headers: uploadResponse.headers)
            generationProgress = 0.4
            
            // 3. Create job
            let jobResponse = try await tensorArtAPI.createJob(
                imageResourceId: uploadResponse.resourceId,
                prompt: prompt,
                negativePrompt: "nsfw, nude, bad anatomy, bad proportions, bad quality"
            )
            generationProgress = 0.6
            
            // 4. Start polling job status
            currentJobId = jobResponse.job.id
            startPollingJobStatus()
            
        } catch {
            isGenerating = false
            showError(error.localizedDescription)
        }
    }
    
    private func startPollingJobStatus() {
        statusCheckTimer?.invalidate()
        statusCheckTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let self = self, let jobId = self.currentJobId else { return }
            
            Task {
                do {
                    let status = try await self.tensorArtAPI.getJobStatus(jobId: jobId)
                    await MainActor.run {
                        self.handleJobStatus(status)
                    }
                } catch {
                    await MainActor.run {
                        self.showError(error.localizedDescription)
                        self.stopGeneration()
                    }
                }
            }
        }
    }
    
    private func handleJobStatus(_ status: TensorArtJobStatus) {
        switch status.job.status {
        case "PENDING":
            generationProgress = 0.7
        case "RUNNING":
            generationProgress = 0.8
        case "SUCCESS":
            currentResult = status
            generationProgress = 1.0
            stopGeneration()
            if !UserManager.shared.isSubscriptionActive ?? false {
                freeCredits -= 1
            }
        case "FAILED":
            showError("Generation failed")
            stopGeneration()
        case "CANCELED":
            showError("Generation was canceled")
            stopGeneration()
        default:
            break
        }
    }
    
    private func stopGeneration() {
        isGenerating = false
        statusCheckTimer?.invalidate()
        statusCheckTimer = nil
        currentJobId = nil
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        isShowingError = true
    }
    
    func saveImageToLibrary() {
        guard let imageUrl = currentResult?.job.successInfo?.images.first?.url,
              let url = URL(string: imageUrl) else {
            showError("No image to save")
            return
        }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                }
            } catch {
                showError("Failed to save image")
            }
        }
    }
    
    func pasteImage() {
        if let image = UIPasteboard.general.image {
            selectedImage = image
        }
    }
}

// MARK: - DEBUG
extension VisionVM {
    // Function to test a fake generation to debug the flow
    func dummyGenerate() {
        DispatchQueue.main.async {
            self.isGenerating = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            self.isGenerating = false
        })
    }
}
