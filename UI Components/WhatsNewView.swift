import SwiftUI

struct WhatsNewView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text("What's new in \(Const.appName)")
                .font(.special(.largeTitle, weight: .semibold))
                .padding(.top)
                .padding(.bottom, 2)
        
            Text("Version \(getAppVersionString())")
                .font(.special(.body, weight: .regular))
                .foregroundStyle(.gray)
            
            ScrollView {
                VStack (spacing: 30) {
                    
                    WhatsNewViewFeature(iconColor: .blue,  icon: "window.shade.closed", featureTitle: "This 'What's new' View", featureSubtitle: "Added this view for the users to see what's new")
                    
                    WhatsNewViewFeature(iconColor: .purple, icon: "moon.stars", featureTitle: "Dark Icon", featureSubtitle: "Add dark and tinted icon according to iOS 18")
                    
                    WhatsNewViewFeature(iconColor: .yellow, icon: "doc.badge.gearshape", featureTitle: "Updated Dependencies", featureSubtitle: "Just upgraded all the the dependencies to the latest versions")
                    
                    WhatsNewViewFeature(iconColor: .accent, icon: "number.circle", featureTitle: "App Version", featureSubtitle: "Added app's version on the Setting's View footer")
                    
                    WhatsNewViewFeature(iconColor: .red, icon: "wrench.and.screwdriver.fill", featureTitle: "Bug Fixes", featureSubtitle: "Fix small bugs and tweak some things")
                }
            }
            .padding(.top, 30)
            
            RoundedButton(title: "All set!") {
                Haptic.shared.lightImpact()
                
                // Update app version
                guard let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
                        return
                }
                
                UserDefaults.standard.set(currentVersion, forKey: "appVersion")
                
                dismiss()
            }
        }
        .padding()
        .background(.customBackground)
    }
 
    func getAppVersionString() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
}

struct WhatsNewViewFeature: View {
    @State var iconColor: Color = .primary
    let icon: String
    let featureTitle: LocalizedStringKey
    let featureSubtitle: LocalizedStringKey
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(iconColor)
                    .font(.title)
                    .frame(minWidth: 50)
                
                VStack {
                    Text(featureTitle)
                        .font(.special(.title3, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(featureSubtitle)
                        .font(.special(.body, weight: .regular))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

#Preview {
    WhatsNewView()
}
