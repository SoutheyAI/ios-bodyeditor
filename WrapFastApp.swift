import SwiftUI
import Firebase
import FirebaseAnalytics
import FirebaseCore
import WishKit
import TipKit

@main
struct WrapFastApp: App {
    
    // MARK: We store in UserDefaults wether the user completed the onboarding and the chosen GPT language.
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = true
    @AppStorage("gptLanguage") var gptLanguage: GPTLanguage = .english
    @AppStorage("systemThemeValue") var systemTheme: Int = ColorSchemeType.dark.rawValue
    
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var purchasesManager = PurchasesManager.shared
    @StateObject var authManager = AuthManager()
    @StateObject var userManager = UserManager.shared
    @StateObject var router: OnboardingRouter = OnboardingRouter()
    
    init() {
        // 检查配置文件
        print("\n📱 应用配置文件检查:")
        
        // 1. 检查主 Bundle 的 Info.plist
        if let bundleInfoPath = Bundle.main.url(forResource: "Info", withExtension: "plist")?.path {
            print("\n1️⃣ 主 Bundle Info.plist:")
            print("• 路径: \(bundleInfoPath)")
            if let infoDict = NSDictionary(contentsOfFile: bundleInfoPath) as? [String: Any] {
                print("• 内容:")
                infoDict.forEach { key, value in
                    print("  - \(key): \(value)")
                }
            }
        }
        
        // 2. 检查项目目录中的 Info.plist
        if let projectInfoPath = Bundle.main.path(forResource: "Info", ofType: "plist", inDirectory: "WrapFast") {
            print("\n2️⃣ 项目目录 Info.plist:")
            print("• 路径: \(projectInfoPath)")
            if let infoDict = NSDictionary(contentsOfFile: projectInfoPath) as? [String: Any] {
                print("• 内容:")
                infoDict.forEach { key, value in
                    print("  - \(key): \(value)")
                }
            }
        }
        
        // 3. 检查 Supporting Files 中的 Info.plist
        if let supportingInfoPath = Bundle.main.path(forResource: "Info", ofType: "plist", inDirectory: "Supporting Files") {
            print("\n3️⃣ Supporting Files Info.plist:")
            print("• 路径: \(supportingInfoPath)")
            if let infoDict = NSDictionary(contentsOfFile: supportingInfoPath) as? [String: Any] {
                print("• 内容:")
                infoDict.forEach { key, value in
                    print("  - \(key): \(value)")
                }
            }
        }
        
        // 4. 打印 Bundle 信息
        print("\n📦 Bundle 信息:")
        print("• Bundle 路径: \(Bundle.main.bundlePath)")
        print("• 可执行文件路径: \(Bundle.main.executablePath ?? "未知")")
        print("• Bundle ID: \(Bundle.main.bundleIdentifier ?? "未知")")
        
        setupFirebase()
        setupWishKit()
        setupTips()
        // 请求追踪权限
        TrackingManager.shared.requestTrackingAuthorization()
//        debugActions()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if !hasCompletedOnboarding {
                    onboarding
                    // MARK: - If you want to configure Crashlytics, uncomment the line below and comment 'onboarding' above.
                    // configureCrashlytics
                    
                    // MARK: - If you don't need User Authentication, remove the following conditionals
                    // and just show 'tabs' view
                } else {
                    tabs
                }
            }
            .preferredColorScheme(selectedScheme)
            .environmentObject(purchasesManager)
            .environmentObject(authManager)
            .environmentObject(userManager)
            .environmentObject(router)
            .onChange(of: scenePhase) { newScenePhase in
                switch newScenePhase {
                case .active:
                    purchasesManager.fetchCustomerInfo()
                    userManager.setAuthenticationState()
                default:
                    break
                }
            }
        }
    }
    
    var onboarding: some View {
        NavigationStack(path: $router.navigationPath) {
            // MARK: - You can change the type of onboarding you want commenting and uncommenting the views.
            // MultiplePagesOnboardingView()
            OnePageOnboardingView()
                .navigationDestination(for: OnboardingRoute.self) { route in
                    switch route {
                    case .requestReview:
                        RequestReviewView()
                  //  case .login:
                    //    LoginView(showPaywallInTheOnboarding: true)
                    default:
                        PaywallView()
                    }
                }
        }
        .tint(.brand)
        
    }
    
    var tabs: some View {
        // MARK: - Add or remove here as many views as tabs you need. It is recommended maximum 5 tabs.
        NavigationStack {
            TabView {
                VisionView()  // 只修改这一行，移除参数
                    .tabItem { Label("Vision", systemImage: "eyes") }
            //    ChatGPTView(vm: ChatGPTVM())
              //      .tabItem { Label("ChatGPT", systemImage: "text.bubble") }
                // DALLEView(vm: DALLEVM())
                //  .tabItem { Label("DALL·E", systemImage: "paintbrush") }
                SettingsView(vm: SettingsVM())
                    .tabItem { Label("Settings", systemImage: "gear") }
            }
            .tint(.brand)
        }
    }
    
#if DEBUG
    var configureCrashlytics: some View {
        
        TestCrashlyticsView()
        
    }
#endif
    
    var selectedScheme: ColorScheme? {
        guard let theme = ColorSchemeType(rawValue: systemTheme) else { return nil}
        switch theme {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
    
    // MARK: Uncomment this method in init() to execute utility actions while developing your app.
    // For example, resetting the onboarding state, deleting free credits from the keychain, etc
    // Feel free to add or comment as many as you need.
    private func debugActions() {
        #if DEBUG
//        KeychainManager.shared.deleteFreeExtraCredits()
//        KeychainManager.shared.setFreeCredits(with: Const.freeCredits)
//        KeychainManager.shared.deleteAuthToken()
//        hasCompletedOnboarding = false
        
        if #available(iOS 17.0, *) {
            // This forces all Tips to show up in every single execution.
            Tips.showAllTipsForTesting()
        }
        
        #endif
    }
    
    private func setupFirebase() {
        print("🔥📱 Firebase - 开始配置")
        
        // 检查配置文件
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
            print("🔥📱 Firebase - 找到配置文件: \(path)")
            if let dict = NSDictionary(contentsOfFile: path) as? [String: Any] {
                print("🔥📱 Firebase - 配置文件内容:")
                if let apiKey = dict["API_KEY"] as? String {
                    print("  • API_KEY: \(String(apiKey.prefix(8)))...")
                }
                print("  • BUNDLE_ID: \(dict["BUNDLE_ID"] ?? "未找到")")
                print("  • PROJECT_ID: \(dict["PROJECT_ID"] ?? "未找到")")
                print("  • STORAGE_BUCKET: \(dict["STORAGE_BUCKET"] ?? "未找到")")
                print("  • GCM_SENDER_ID: \(dict["GCM_SENDER_ID"] ?? "未找到")")
                print("  • GOOGLE_APP_ID: \(dict["GOOGLE_APP_ID"] ?? "未找到")")
                
                // 验证配置
                if let bundleId = dict["BUNDLE_ID"] as? String,
                   bundleId != Bundle.main.bundleIdentifier {
                    print("🔥‼️ Firebase - Bundle ID 不匹配")
                    print("  • 配置文件中: \(bundleId)")
                    print("  • 应用实际值: \(Bundle.main.bundleIdentifier ?? "未知")")
                }
                
                if let projectId = dict["PROJECT_ID"] as? String,
                   projectId == "mockproject-1234" {
                    print("🔥‼️ Firebase - 检测到示例项目 ID，请使用真实的 Firebase 项目配置")
                }
            } else {
                print("🔥‼️ Firebase - 无法读取配置文件内容")
            }
        } else {
            print("🔥‼️ Firebase - 未找到 GoogleService-Info.plist 文件")
        }
        
        FirebaseApp.configure()
        print("🔥📱 Firebase - 基础配置完成")
        
        // 检查 Firebase 配置
        if let app = FirebaseApp.app() {
            print("🔥✅ Firebase - 应用配置成功:")
            print("  • 应用名称: \(app.name)")
            let options = app.options
            print("  • API Key: \(String(options.apiKey?.prefix(8) ?? ""))...")
            print("  • Project ID: \(options.projectID ?? "未找到")")
        } else {
            print("🔥‼️ Firebase - 应用配置失败")
        }
        
        Analytics.setAnalyticsCollectionEnabled(true)
        print("🔥📊 Firebase - Analytics 已启用")
        
        #if DEBUG
        Analytics.setAnalyticsCollectionEnabled(false)
        print("🔥📊 Firebase - DEBUG 模式：Analytics 已禁用")
        #endif
        
        if isTestFlight() {
            Analytics.setAnalyticsCollectionEnabled(false)
            print("🔥📊 Firebase - TestFlight 模式：Analytics 已禁用")
        }
        
        // 检查 Installation ID
        Installations.installations().installationID { (id, error) in
            if let error = error {
                print("🔥‼️ Firebase - 获取 Installation ID 失败: \(error.localizedDescription)")
            } else if let id = id {
                print("🔥✅ Firebase - Installation ID: \(id)")
            }
        }
        
        print("🔥✅ Firebase - 配置完成")
    }
    
    // Customer Feedback Support.
    // https://github.com/wishkit/wishkit-iosse
    private func setupWishKit() {
        WishKit.configure(with: Const.WishKit.key)
        
        // Show the status badge of a feature request (e.g. pending, approved, etc.).
        WishKit.config.statusBadge = .show

        // Shows full description of a feature request in the list.
        WishKit.config.expandDescriptionInList = true

        // Hide the segmented control.
        WishKit.config.buttons.segmentedControl.display = .hide

        // Remove drop shadow.
        WishKit.config.dropShadow = .hide

        // Hide comment section
        WishKit.config.commentSection = .hide

        // Position the Add-Button.
        WishKit.config.buttons.addButton.bottomPadding = .large

        // This is for the Add-Button, Segmented Control, and Vote-Button.
        WishKit.theme.primaryColor = .brand

        // Set the secondary color (this is for the cells and text fields).
        WishKit.theme.secondaryColor = .set(light: .brand.opacity(0.1), dark: .brand.opacity(0.05))

        // Set the tertiary color (this is for the background).
        WishKit.theme.tertiaryColor = .setBoth(to: .customBackground)

        // Segmented Control (Text color)
        WishKit.config.buttons.segmentedControl.defaultTextColor = .setBoth(to: .white)

        WishKit.config.buttons.segmentedControl.activeTextColor = .setBoth(to: .white)

        // Save Button (Text color)
        WishKit.config.buttons.saveButton.textColor = .set(light: .white, dark: .white)

    }
    
    // Check this nice tutorial for more Tip configurations:
    // https://asynclearn.medium.com/suggesting-features-to-users-with-tipkit-8128178d6114
    private func setupTips() {
        if #available(iOS 17, *) {
            try? Tips.configure([
                .displayFrequency(.immediate)
              ])
        }
    }
    
    private func isTestFlight() -> Bool {
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL else {
            return false
        }
        
        return appStoreReceiptURL.lastPathComponent == "sandboxReceipt"
    }
}
