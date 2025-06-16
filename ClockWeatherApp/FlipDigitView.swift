
import SwiftUI

struct FlipDigitView: View {
    /// The digit currently being displayed.
    let digit: String

    /// The digit that was previously shown. Used for the flip animation.
    @State private var previousDigit: String = ""
    /// Rotation value used to create a simple flip effect.
    @State private var rotation: Double = 0

    var body: some View {
        Text(previousDigit)
            .font(.system(size: 60, weight: .bold, design: .rounded))
            .frame(width: 80, height: 100)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray.opacity(0.4)),
                alignment: .center
            )
            .rotation3DEffect(.degrees(rotation), axis: (x: 1, y: 0, z: 0))
            .onAppear { previousDigit = digit }
            .onChange(of: digit) { _, newValue in
                // Animate the digit flipping over when it changes.
                withAnimation(.easeInOut(duration: 0.25)) {
                    rotation = -90
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    previousDigit = newValue
                    rotation = 90
                    withAnimation(.easeInOut(duration: 0.25)) {
                        rotation = 0
                    }
                }
            }
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
