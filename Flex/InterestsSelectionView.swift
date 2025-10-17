import SwiftUI

struct InterestSelectionView: View {
    let interests = [
        "Music", "Movies", "Travel", "Sports",
        "Cooking", "Technology", "Art", "Fitness",
        "Reading", "Gaming", "Photography", "Fashion"
    ]
    
    @State private var selectedInterests: Set<String> = []
    var onContinue: ((Set<String>) -> Void)?
    
    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 12)
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Select Your Interests")
                .font(Theme.headingFont())
                .foregroundStyle(Theme.accentMuted)
                .padding(.top, 24)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(interests, id: \.self) { interest in
                        Button(action: {
                            toggleInterest(interest)
                        }) {
                            Text(interest)
                                .font(.body)
                                .foregroundStyle(selectedInterests.contains(interest) ? Theme.textPrimary : Theme.textSecondary)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(selectedInterests.contains(interest) ? Theme.surfaceElevated : Theme.surface)
                                        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Theme.divider, lineWidth: 1))
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 24)
            }
            
            Button(action: {
                onContinue?(selectedInterests)
            }) {
                Text("Continue")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Theme.surface)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.divider, lineWidth: 1))
                    )
                    .foregroundStyle(Theme.accentMuted)
                    .padding(.horizontal, 24)
            }
            .disabled(selectedInterests.isEmpty)
            .padding(.bottom, 24)
        }
        .background(Theme.bg.ignoresSafeArea())
    }
    
    private func toggleInterest(_ interest: String) {
        if selectedInterests.contains(interest) {
            selectedInterests.remove(interest)
        } else {
            selectedInterests.insert(interest)
        }
    }
}

struct InterestSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        InterestSelectionView { selected in
            print("Selected interests: \(selected)")
        }
    }
}
