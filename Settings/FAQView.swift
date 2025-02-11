import SwiftUI

struct FAQView: View {
    @Environment(\.dismiss) var dismiss
    
    private let faqContent = """
# Frequently Asked Questions

## What is Perfect BodyEditor?
Perfect BodyEditor is an advanced AI-powered app that helps you visualize body transformations. Using cutting-edge artificial intelligence, it allows you to see potential changes to your body shape and features in a realistic and natural way.

## How does it work?
1. Upload a photo from your library or take a new one
2. Describe your desired body transformation
3. Let our AI technology create a natural-looking result
4. Save or share your transformed image

## Is it safe to use?
Yes! We prioritize your privacy and safety:
- All images are processed securely
- Your photos are never stored permanently
- We use advanced AI to ensure natural-looking results
- All transformations maintain realistic body proportions

## What types of photos work best?
For optimal results, we recommend:
- Full-body photos when possible
- Clear, well-lit images
- Simple backgrounds
- Fitted clothing
- Front-facing or side views
- Good quality, non-blurry photos

## How many transformations do I get with the free version?
The free version includes a limited number of transformations. For unlimited transformations and premium features, consider upgrading to our Premium plan.

## How long does the transformation process take?
Typically 20-30 seconds, depending on:
- Image complexity
- Server load
- Internet connection
Premium users receive priority processing.

## What if I'm not satisfied with the results?
You can try:
- Using different photos
- Adjusting your description
- Being more specific with your transformation goals
- Trying different angles or poses
- Generating multiple variations

## Can I save and share my transformations?
Yes! You can:
- Save images to your photo library
- Share directly with friends
- Export in high quality
- Use in other apps

## Is my privacy protected?
Absolutely! We take privacy seriously:
- End-to-end encryption
- No permanent storage of your photos
- Secure processing
- Private transformations
- GDPR compliant

## How do I cancel my subscription?
You can manage your subscription in iPhone Settings:
1. Open Settings
2. Tap your Apple ID
3. Select Subscriptions
4. Find Perfect BodyEditor
5. Manage or cancel your subscription

## Need help or have questions?
Contact our support team at support@perfectbodyeditor.com for assistance.
"""
    
    var body: some View {
        ZStack {
            ScrollView {
                Text("Frequently Asked Questions")
                    .font(.title)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                Text(faqContent)
                .padding()
                
                TermsAndPrivacyPolicyView()
            }
        }
        .background(.customBackground)
        .toolbar(.hidden, for: .tabBar)
        .task {
            Tracker.openedFaq()
        }
    }
}

#Preview {
    FAQView()
}
