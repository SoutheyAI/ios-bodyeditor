import SwiftUI
import StoreKit

struct RequestReviewView: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @EnvironmentObject var router: OnboardingRouter
    @State var buttonPressed = false
    
    // MARK: This delay is to give time to the users to do the review rather than
    //leaving them to another view instantly. You can tweak it as you want.
    @State var advanceToNextViewDelay: CGFloat = 2
    
    var body: some View {
        VStack {
            Text("Help Us Grow")
                .minimumScaleFactor(0.7)
                .font(.special(.largeTitle, weight: .bold))
                .padding()
            
            Image(systemName: "heart.fill")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 250)
                .padding(.vertical)
                .foregroundStyle(.red.gradient)
            
            Text("Show your love by giving as a review on the App Store")
                .font(.special(.title2, weight: .regular))
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.center)
                .lineLimit(/*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/)
                .padding(.horizontal)
        }
        .navigationBarBackButtonHidden()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.customBackground)
        .safeAreaInset(edge: .bottom, content: {
            ZStack {
                RoundedButton(title: buttonPressed ? "" : "Continue") {
                    buttonPressed = true
                    requestReview()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + advanceToNextViewDelay, execute: {
                        buttonPressed = false
                        // MARK: - If you wish to end the onboarding here, rather than request authentication, just
                        // remove the navigation below and uncomment hasCompletedOnboarding
                        router.navigateTo(route: .login)
                        // hasCompletedOnboarding = true
                    })
                }
                .padding()
                
                if buttonPressed {
                    ProgressView()
                        .offset(y: -50)
                }
            }
        })
    }
    
    func requestReview() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}

#Preview {
    RequestReviewView()
        .environmentObject(OnboardingRouter())
}
