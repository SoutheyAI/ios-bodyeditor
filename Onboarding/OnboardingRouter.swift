import SwiftUI
import Observation

enum OnboardingRoute: Hashable {
    case features
    case requestReview
    case login
}

class OnboardingRouter: ObservableObject {
    @Published var navigationPath = NavigationPath()

    func navigateTo(route: OnboardingRoute) {
        navigationPath.append(route)
    }
}
