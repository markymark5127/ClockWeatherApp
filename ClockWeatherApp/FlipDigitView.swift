
import SwiftUI

struct FlipDigitView: View {
    let digit: String

    var body: some View {
        Text(digit)
            .font(.system(size: 60, weight: .bold, design: .rounded))
            .frame(width: 80, height: 100)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray.opacity(0.4)),
                alignment: .center
            )
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
