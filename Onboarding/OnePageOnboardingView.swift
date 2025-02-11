import SwiftUI

struct OnePageOnboardingView: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @EnvironmentObject var router: OnboardingRouter
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Text("Welcome to\n✨Body Editor✨")
                    .font(.special(.largeTitle, weight: .black))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 24)
                
                VStack(alignment: .leading, spacing: 16) {
                    OnboardingFeature(image: Image(systemName: "person.crop.rectangle.stack.fill"),
                                      imageColor: .brand,
                                      title: "AI Body Enhancement",
                                      description: "Transform your body shape with advanced AI technology")
                    
                    OnboardingFeature(image: Image(systemName: "sparkles.rectangle.stack"),
                                      imageColor: .ruby,
                                      title: "Smart Transformation",
                                      description: "Customize your body features with intelligent editing tools")
                    
                    OnboardingFeature(image: Image(systemName: "wand.and.stars.inverse"),
                                      imageColor: .blue,
                                      title: "Natural Results",
                                      description: "Get realistic and natural-looking transformations instantly")
                                      
                    OnboardingFeature(image: Image(systemName: "lock.shield.fill"),
                                      imageColor: .green,
                                      title: "Private & Secure",
                                      description: "Your photos and edits are completely private and secure")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                RoundedButton(title: "Get Started") {
                    Haptic.shared.lightImpact()
                    router.navigateTo(route: .requestReview)
                }
            }
            .padding(40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.customBackground)
    }
}

#Preview {
    OnePageOnboardingView()
        .environmentObject(OnboardingRouter())
}
