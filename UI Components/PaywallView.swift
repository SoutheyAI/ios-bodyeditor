import SwiftUI
import RevenueCat
import RevenueCatUI

// MARK: - 付费墙界面
/// 显示应用的高级功能和订阅选项
struct PaywallView: View {
    // MARK: - Properties
    /// 用户管理器，处理用户状态和权限
    @EnvironmentObject var userManager: UserManager
    /// 购买管理器，处理订阅和支付
    @EnvironmentObject var purchasesManager: PurchasesManager
    /// 用于关闭当前视图
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        // MARK: - 主界面布局
        ZStack {
            ScrollView {
                VStack {
                    // MARK: - Logo 和标题区域
                    VStack(spacing: 0) {
                        // App Logo
                        Image("app-logo")
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 50)
                        
                        // Premium 标题
                        Text("P R E M I U M")
                            .font(.special(.largeTitle, weight: .black))
                            .foregroundStyle(Color.ruby.gradient)
                    }
                    .onAppear {
                        print("💰 PaywallView - 开始加载付费墙界面")
                        
                        // 打印 RevenueCat Offering 详细信息
                        if let offering = purchasesManager.currentOffering {
                            print("\n💰 当前 Offering 详细信息:")
                            print("• Offering ID: \(offering.identifier)")
                            print("• 服务器描述: \(offering.serverDescription ?? "无")")
                            print("• Offering 元数据: \(offering.metadata)")
                            
                            // 检查付费墙配置
                            if let paywall = offering.paywall {
                                print("\n💰 付费墙配置详情:")
                                print("• 付费墙对象: \(paywall)")
                                print("• 付费墙类型: \(type(of: paywall))")
                                
                                // 尝试获取和打印所有可用的属性
                                let mirror = Mirror(reflecting: paywall)
                                print("\n💰 付费墙所有属性:")
                                for child in mirror.children {
                                    if let label = child.label {
                                        print("• \(label): \(child.value)")
                                    }
                                }
                            } else {
                                print("\n⚠️ 付费墙未配置")
                                print("请检查:")
                                print("1. RevenueCat Offering ID: \(offering.identifier)")
                                print("2. 后台付费墙配置状态")
                                print("3. 付费墙是否已发布")
                            }
                            
                            // 打印可用产品信息
                            print("\n📦 可用产品:")
                            offering.availablePackages.forEach { package in
                                print("\n• \(package.identifier):")
                                print("  - 产品ID: \(package.storeProduct.productIdentifier)")
                                print("  - 价格: \(package.storeProduct.localizedPriceString)")
                                print("  - 标题: \(package.storeProduct.localizedTitle)")
                                print("  - 描述: \(package.storeProduct.localizedDescription)")
                            }
                        }
                    }
                    
                    // MARK: - 功能列表
                    VStack(alignment: .leading, spacing: 12) {
                        // 1. 无限次数的身体编辑
                        PaywallFeature(title: "✨ Unlimited Body Transformations",
                                       description: "Transform your body with unlimited AI-powered edits to achieve your ideal look.")
                        
                        // 2. 高级编辑效果
                        PaywallFeature(title: "🎯 Advanced Editing Effects",
                                       description: "Access professional-grade body sculpting tools and advanced transformation features.")
                        
                        // 3. 优先处理
                        PaywallFeature(title: "⚡️ Priority Processing",
                                       description: "Enjoy VIP-exclusive fast processing for quicker transformation results.")
                        
                        // 4. 隐私保护
                        PaywallFeature(title: "🔒 Privacy Protection",
                                       description: "Enterprise-grade encryption ensures your photos are secure and private.")
                        
                        // 5. 专业 AI 模型
                        PaywallFeature(title: "🎨 Professional AI Model",
                                       description: "Utilize our specially trained AI model for natural and realistic body transformations.")
                        
                        // 6. 支持独立开发
                        PaywallFeature(title: "♥️ Support Independent Development",
                                       description: "Crafted with care by an independent developer 👨🏻‍💻. Your support helps us deliver better features.")
                    }
                    .onAppear {
                        print("💰 PaywallView - 功能列表已加载")
                        print("💰 PaywallView - 当前用户订阅状态: \(userManager.isSubscriptionActive ?? false)")
                        if let offering = purchasesManager.currentOffering {
                            print("💰 PaywallView - 已获取到商品列表:")
                            print("  • Offering ID: \(offering.identifier)")
                            if let monthly = offering.monthly {
                                print("  • 月度订阅价格: \(monthly.storeProduct.localizedPriceString)")
                            }
                            if let annual = offering.annual {
                                print("  • 年度订阅价格: \(annual.storeProduct.localizedPriceString)")
                            }
                        } else {
                            print("💰❌ PaywallView - 未获取到商品列表")
                        }
                    }
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal)
                    
                    // MARK: - 隐私政策和使用条款
                    VStack(spacing: 8) {
                        Text("By continuing, you agree to our")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            Button("Terms of Use") {
                                if let url = URL(string: "https://sites.google.com/view/bodyeditor-terms/") {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .font(.footnote)
                            .foregroundColor(.brand)
                            
                            Text("and")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            
                            Button("Privacy Policy") {
                                if let url = URL(string: "https://sites.google.com/view/bodyeditor-privacy/") {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .font(.footnote)
                            .foregroundColor(.brand)
                        }
                    }
                    .padding(.bottom)
                }
            }
            
            // MARK: - 关闭按钮
            Button("", systemImage: "xmark") {
                print("💰 PaywallView - 用户点击关闭按钮")
                dismiss()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.horizontal)
            .font(.special(.title3, weight: .regular))
            .foregroundStyle(.brand.opacity(purchasesManager.closeButtonOpacity))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.customBackground)
        .navigationBarBackButtonHidden()
        // 使用 RevenueCat 提供的标准付费墙底部
        .paywallFooter()
        
        // MARK: - 购买完成处理
        .onPurchaseCompleted { customerInfo in
            print("\n💰 PaywallView - 收到购买完成回调")
            if customerInfo.entitlements.all[Const.Purchases.premiumEntitlementIdentifier]?.isActive == true {
                print("💰✅ PaywallView - 购买成功，权益已激活")
                print("  • 用户ID: \(customerInfo.originalAppUserId)")
                print("  • 权益ID: \(Const.Purchases.premiumEntitlementIdentifier)")
                print("  • 过期时间: \(customerInfo.entitlements.all[Const.Purchases.premiumEntitlementIdentifier]?.expirationDate?.description ?? "永不")")
                Logger.log(message: "Premium purchased!", event: .info)
                Tracker.purchasedPremium()
                userManager.isSubscriptionActive = true
                dismiss()
            } else {
                print("💰❌ PaywallView - 购买可能成功但权益未激活")
                print("  • 用户ID: \(customerInfo.originalAppUserId)")
                print("  • 所有权益: \(customerInfo.entitlements.all.keys.joined(separator: ", "))")
                print("  • 请检查权益ID是否正确: \(Const.Purchases.premiumEntitlementIdentifier)")
            }
        }
        
        // MARK: - 恢复购买处理
        .onRestoreCompleted { customerInfo in
            print("\n💰 PaywallView - 收到恢复购买回调")
            if customerInfo.entitlements.all[Const.Purchases.premiumEntitlementIdentifier]?.isActive == true {
                print("💰✅ PaywallView - 恢复购买成功，权益已激活")
                print("  • 用户ID: \(customerInfo.originalAppUserId)")
                print("  • 权益ID: \(Const.Purchases.premiumEntitlementIdentifier)")
                print("  • 过期时间: \(customerInfo.entitlements.all[Const.Purchases.premiumEntitlementIdentifier]?.expirationDate?.description ?? "永不")")
                Logger.log(message: "Restore purchases completed!", event: .info)
                Tracker.restoredPurchase()
                userManager.isSubscriptionActive = true
                dismiss()
            } else {
                print("💰❌ PaywallView - 恢复购买失败或无可恢复的购买")
                print("  • 用户ID: \(customerInfo.originalAppUserId)")
                print("  • 所有权益: \(customerInfo.entitlements.all.keys.joined(separator: ", "))")
                print("  • 请检查是否有过往的有效购买")
            }
        }
        .onAppear {
            print("\n💰 PaywallView - 付费墙视图已显示")
            print("💰 PaywallView - RevenueCat 配置信息:")
            print("  • API Key: \(String(Const.Purchases.key.prefix(8)))...")
            print("  • 权益ID: \(Const.Purchases.premiumEntitlementIdentifier)")
            print("  • Bundle ID: \(Bundle.main.bundleIdentifier ?? "未知")")
            
            // 检查商品列表
            if let offering = purchasesManager.currentOffering {
                print("💰 PaywallView - 已获取到商品列表:")
                print("  • Offering ID: \(offering.identifier)")
                if let monthly = offering.monthly {
                    print("  • 月度订阅价格: \(monthly.storeProduct.localizedPriceString)")
                }
                if let annual = offering.annual {
                    print("  • 年度订阅价格: \(annual.storeProduct.localizedPriceString)")
                }
            } else {
                print("💰❌ PaywallView - 未获取到商品列表")
                print("💰❌ 请检查:")
                print("  1. RevenueCat API Key 是否正确")
                print("  2. App Store Connect 中的商品配置")
                print("  3. RevenueCat 后台的商品配置")
                print("  4. 网络连接状态")
            }
            
            // 检查用户状态
            print("💰 PaywallView - 用户状态:")
            print("  • 订阅状态: \(userManager.isSubscriptionActive ?? false)")
            print("  • 用户ID: \(userManager.userId)")
        }
    }
}

// MARK: - 预览
#Preview {
    PaywallView()
        .environmentObject(UserManager.shared)
        .environmentObject(PurchasesManager.shared)
}
