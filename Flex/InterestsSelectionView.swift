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
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 24)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(interests, id: \.self) { interest in
                        Button(action: {
                            toggleInterest(interest)
                        }) {
                            Text(interest)
                                .font(.body)
                                .foregroundColor(selectedInterests.contains(interest) ? .white : .primary)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(selectedInterests.contains(interest) ? Color.accentColor : Color(.systemGray5))
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
                    .background(selectedInterests.isEmpty ? Color.gray.opacity(0.5) : Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
            }
            .disabled(selectedInterests.isEmpty)
            .padding(.bottom, 24)
        }
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
