import Foundation
import AppTrackingTransparency
import AdSupport

class TrackingManager {
    static let shared = TrackingManager()
    
    private init() {}
    
    private func checkTrackingConfiguration() {
        print("\n📱 追踪配置检查:")
        
        // 检查 Info.plist 位置
        if let infoPlistPath = Bundle.main.url(forResource: "Info", withExtension: "plist")?.path {
            print("• Info.plist 路径: \(infoPlistPath)")
            
            // 读取 Info.plist 内容
            if let infoDict = NSDictionary(contentsOfFile: infoPlistPath) as? [String: Any] {
                if let trackingDescription = infoDict["NSUserTrackingUsageDescription"] as? String {
                    print("• 追踪权限描述: \(trackingDescription)")
                } else {
                    print("⚠️ 警告: 未找到追踪权限描述 (NSUserTrackingUsageDescription)")
                }
            }
        } else {
            print("⚠️ 警告: 未找到 Info.plist 文件")
        }
        
        // 检查当前追踪状态
        let status = ATTrackingManager.trackingAuthorizationStatus
        print("• 当前追踪状态: \(statusDescription(status))")
        
        // 检查 IDFA
        let idfa = ASIdentifierManager.shared().advertisingIdentifier
        print("• IDFA: \(idfa)")
        print("• IDFA 启用状态: \(ASIdentifierManager.shared().isAdvertisingTrackingEnabled)")
    }
    
    private func statusDescription(_ status: ATTrackingManager.AuthorizationStatus) -> String {
        switch status {
        case .authorized:
            return "已授权"
        case .denied:
            return "已拒绝"
        case .notDetermined:
            return "未确定"
        case .restricted:
            return "受限制"
        @unknown default:
            return "未知状态"
        }
    }
    
    func requestTrackingAuthorization() {
        print("\n🔍 准备请求追踪权限...")
        
        // 检查当前状态
        let currentStatus = ATTrackingManager.trackingAuthorizationStatus
        print("• 当前追踪状态: \(statusDescription(currentStatus))")
        print("• IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
        
        // 延迟请求，等待应用完全启动
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print("🔍 开始请求追踪权限")
            ATTrackingManager.requestTrackingAuthorization { status in
                print("\n📱 追踪授权结果:")
                print("• 状态: \(self.statusDescription(status))")
                
                switch status {
                case .authorized:
                    print("✅ 用户允许追踪")
                    print("• IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
                    // 这里可以初始化 Facebook SDK 或其他需要 IDFA 的服务
                    self.setupTrackingServices()
                case .denied:
                    print("❌ 用户拒绝追踪")
                    print("提示: 用户可以在系统设置中修改此权限")
                case .notDetermined:
                    print("⚠️ 用户未做选择")
                case .restricted:
                    print("⚠️ 追踪受限制")
                    print("可能原因: 设备限制或家长控制等")
                @unknown default:
                    print("❓ 未知状态")
                }
            }
        }
    }
    
    private func setupTrackingServices() {
        print("\n🔄 初始化追踪服务:")
        // 用户同意追踪后，在这里初始化相关服务
        // 例如：Facebook SDK、广告追踪等
        print("• 开始设置追踪服务")
        print("• IDFA 可用性: \(ASIdentifierManager.shared().isAdvertisingTrackingEnabled)")
    }
    
    func getTrackingAuthorizationStatus() -> ATTrackingManager.AuthorizationStatus {
        return ATTrackingManager.trackingAuthorizationStatus
    }
} 