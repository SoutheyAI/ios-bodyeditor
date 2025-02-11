import SwiftUI

struct MultiplePagesOnboardingView: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @State private var selectedTab = 0
    @EnvironmentObject var router: OnboardingRouter
    
    // MARK: - Place in the array as many onboarding pages as you want.
    // Recommended 3 to 5 max. Don't overwhelm the user. Be clear and concise in your texts.
    @State private var pages: [MultiplePagesOnboardingFeatureModel] = [
        .init(imageName: "app-logo", 
              title: "Welcome to ✨\(Const.appName)🎨!", 
              description: "Your AI Background Generator"),
        
        .init(imageName: "onboarding1", 
              title: "AI-Powered Creation", 
              description: "Create stunning backgrounds with advanced AI technology"),
        
        .init(imageName: "onboarding2", 
              title: "Endless Possibilities", 
              description: "Generate unique backgrounds in any style - abstract, minimal, nature and more"),
        
        .init(imageName: "onboarding3", 
              title: "Perfect for Any Use", 
              description: "High-quality backgrounds for social media, presentations, websites and more")
    ]
    
    init() {
        setupPageIndicatorColor()
    }
    
    private func setupPageIndicatorColor() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .brand
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.brand.withAlphaComponent(0.2)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                TabView(selection: $selectedTab) {
                    ForEach(Array(pages.enumerated()), id: \.element) { index, page in
                        MultiplePagesOnboardingFeature(model: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                
                RoundedButton(title: "Continue") {
                    advanceIfPossible()
                }
            }
            .padding(20)
        }
        .background(.customBackground)
    }
    
    private func advanceIfPossible() {
        if selectedTab < (pages.count - 1) {
            withAnimation {
                selectedTab += 1
            }
        } else {
            // MARK: - If you want to skip request review and navigate directly to LoginView or
            // any other view, just replace the line below and add the proper view you wish.
            // Even that requesting the review without trying the app could feel dumb, evidences
            // have demonstrated that this converts so much:
            // https://x.com/evgeniymikholap/status/1714612296117608571?s=20
            // Other strategy is requesting review after a success moment. For example in a to-do list app,
            // after completing one ore several tasks.
            // It's important to know that you only have 3 ATTEMPTS PER YEAR to request a review, so place them wisely.
            router.navigateTo(route: .requestReview)
        }
    }
}

#Preview {
    MultiplePagesOnboardingView()
        .environmentObject(OnboardingRouter())
}
