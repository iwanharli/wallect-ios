import SwiftUI

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Theme.accent : Theme.cardBackground.opacity(0.3))
                .foregroundColor(isSelected ? .black : Theme.textSecondary)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Theme.accent.opacity(0.5) : Color.white.opacity(0.05), lineWidth: 0.5)
                )
        }
    }
}
