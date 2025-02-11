import SwiftUI
import TipKit
import UIKit

struct StyleItem: Identifiable {
    let id = UUID()
    let image: String  // 图片名称或URL
    let name: String   // 样式名称
    let isPro: Bool    // 是否为专业版功能
}

struct StyleCard: View {
    let style: StyleItem
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    // 样式图片
                    Image(style.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipped()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    isSelected ?
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.cyan, Color.green]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ) : LinearGradient(
                                        gradient: Gradient(colors: [Color.clear, Color.clear]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                    
                    // PRO 标签
                    if style.isPro {
                        Text("PRO")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.cyan, Color.green]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                            .padding(8)
                    }
                }
                
                Text(style.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }
        }
    }
}

struct VisionView: View {
    @StateObject private var vm = VisionVM()
    @State private var isShowingImagePicker = false
    @State private var isShowingPaywall = false
    @State private var source: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedStyle: StyleItem?  // 添加选中样式状态
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var userManager: UserManager
    
    // 预定义的样式选项
    private let styles = [
        StyleItem(image: "1", name: "Beach Style", isPro: false),
        StyleItem(image: "2", name: "Fashion Model", isPro: true),
        StyleItem(image: "3", name: "Fitness Model", isPro: false),
        StyleItem(image: "4", name: "Glamour", isPro: true),
        StyleItem(image: "5", name: "Portrait", isPro: false),
        StyleItem(image: "6", name: "Summer Style", isPro: true)
    ]
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.black,
                Color.black.opacity(0.8)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 25) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Perfect Body Generator")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                    Text("Create your dream body in seconds")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                imageSection
                styleSection
                promptSection
                generateButton
                progressSection
                resultSection
                creditsSection
            }
            .padding(.vertical)
        }
    }
    
    private var imageSection: some View {
        Group {
            if let selectedImage = vm.selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(20)
                    .shadow(color: Color.cyan.opacity(0.3), radius: 10, x: 0, y: 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.cyan, Color.green]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .padding(.horizontal)
            } else {
                Button {
                    source = .photoLibrary
                    isShowingImagePicker = true
                } label: {
                    VStack(spacing: 12) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 32))
                        Text("Add a reference image")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.cyan.opacity(0.2), Color.green.opacity(0.2)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.cyan.opacity(0.3), Color.green.opacity(0.3)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1
                            )
                    )
                }
                .foregroundColor(.white)
                .padding(.horizontal)
            }
        }
    }
    
    private var styleSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题栏
            HStack {
                Text("Style")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Button("See All") {
                    // 处理查看所有样式的操作
                }
                .foregroundColor(.cyan)
            }
            .padding(.horizontal)
            
            // 水平滚动的样式列表
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(styles) { style in
                        StyleCard(
                            style: style,
                            isSelected: selectedStyle?.id == style.id
                        ) {
                            if style.isPro && !(userManager.isSubscriptionActive ?? false) {
                                isShowingPaywall.toggle()
                            } else {
                                selectedStyle = style
                                // 这里可以添加选择样式后的其他操作
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var promptSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Enter Your Perfect Prompt")
                .font(.headline)
                .foregroundColor(.white)
            
            TextEditor(text: $vm.prompt)
                .frame(height: 80)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .foregroundColor(.white)
        }
        .padding(.horizontal)
    }
    
    private var generateButton: some View {
        Button {
            Task {
                if vm.canGenerate() {
                    await vm.generateBackground()
                } else {
                    isShowingPaywall.toggle()
                }
            }
        } label: {
            HStack(spacing: 12) {
                if vm.isGenerating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.trailing, 8)
                }
                Text(vm.isGenerating ? "Processing..." : "Transform Now")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.cyan, Color.green]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .opacity(vm.canGenerate() ? 1 : 0.5)
            )
            .cornerRadius(28)
            .shadow(
                color: Color.cyan.opacity(0.5),
                radius: 10,
                x: 0,
                y: 5
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.cyan.opacity(0.5), Color.green.opacity(0.5)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1
                    )
            )
        }
        .disabled(vm.isGenerating || vm.selectedImage == nil || vm.prompt.isEmpty)
        .padding(.horizontal)
    }
    
    private var progressSection: some View {
        Group {
            if vm.isGenerating {
                VStack(spacing: 12) {
                    ProgressView(value: vm.generationProgress)
                        .progressViewStyle(.linear)
                        .tint(Color.cyan)
                    Text("Creating your perfect transformation...")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(15)
                .padding(.horizontal)
            }
        }
    }
    
    private var resultSection: some View {
        Group {
            if let result = vm.currentResult {
                Group {
                    let _ = print("📦 获取到结果: \(result)")
                    let _ = result.job.successInfo.map { successInfo in
                        print("✨ 成功信息: \(successInfo)")
                        if let imageUrl = successInfo.images.first?.url {
                            print("🖼 生成的图片URL: \(imageUrl)")
                        }
                    }
                    
                    if let url = URL(string: result.job.successInfo?.images.first?.url ?? "") {
                        AsyncImage(url: url) { phase in
                            Group {
                                switch phase {
                                case .empty:
                                    let _ = print("🔄 正在加载图片...")
                                    ProgressView()
                                case .success(let image):
                                    let _ = print("✅ 图片加载成功")
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .cornerRadius(20)
                                        .shadow(color: Color.accentColor.opacity(0.3), radius: 10, x: 0, y: 5)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.accentColor.opacity(0.3), lineWidth: 2)
                                        )
                                case .failure(let error):
                                    let _ = print("❌ 图片加载失败: \(error.localizedDescription)")
                                    Text("Failed to Load")
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                        .frame(maxHeight: 300)
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    private var creditsSection: some View {
        Group {
            if !userManager.isSubscriptionActive ?? false {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Free Transformations Left: \(vm.freeCredits)")
                }
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.cyan.opacity(0.3), Color.green.opacity(0.3)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                mainContent
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button {
                            source = .photoLibrary
                            isShowingImagePicker = true
                        } label: {
                            Label("Choose from Library", systemImage: "photo.on.rectangle")
                        }
                        
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            Button {
                                source = .camera
                                isShowingImagePicker = true
                            } label: {
                                Label("Take Photo", systemImage: "camera")
                            }
                        }
                        
                        Button {
                            vm.pasteImage()
                        } label: {
                            Label("Paste from Clipboard", systemImage: "doc.on.clipboard")
                        }
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                }
                
                if vm.selectedImage != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            vm.saveImageToLibrary()
                        } label: {
                            Image(systemName: "square.and.arrow.down")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(selectedImage: $vm.selectedImage, sourceType: source)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $isShowingPaywall) {
            PaywallView()
        }
        .alert("Error", isPresented: $vm.isShowingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.errorMessage)
        }
        .onChange(of: vm.selectedImage) { newImage in
            print("📸 图片选择状态改变: \(newImage != nil ? "已选择" : "未选择")")
        }
        .onChange(of: vm.isGenerating) { isGenerating in
            print("⚙️ 生成状态改变: \(isGenerating ? "正在生成" : "生成结束")")
        }
        .onChange(of: vm.errorMessage) { error in
            if !error.isEmpty {
                print("⚠️ 发生错误: \(error)")
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct ImagePlaceholderView: View {
    var onTap: () -> Void
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.secondary.opacity(0.1))
            .overlay(
                VStack(spacing: 16) {
                    Image(systemName: "person.crop.rectangle.stack")
                        .font(.system(size: 40))
                        .foregroundColor(.accentColor)
                    Text("Select Reference Image")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.accentColor.opacity(0.3), lineWidth: 2)
                    .shadow(color: Color.accentColor.opacity(0.2), radius: 8, x: 0, y: 4)
            )
            .padding(.horizontal)
            .onTapGesture {
                onTap()
            }
    }
}

#Preview {
    VisionView()
        .environmentObject(UserManager.shared)
}
