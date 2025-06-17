
import SwiftUI

struct FlipDigitView: View {
    /// The digit currently being displayed.
    let digit: String

    /// The digit that was previously shown. Used for the flip animation.
    @State private var previousDigit: String = ""

    /// Rotation amounts for the top and bottom halves of the card.
    @State private var topRotation: Double = 0
    @State private var bottomRotation: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            // Top half
            ZStack {
                Text(previousDigit)
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .frame(width: 80, height: 50)
                    .foregroundStyle(.primary)
                    .background(.ultraThinMaterial)
                    .clipped()

                Text(digit)
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .frame(width: 80, height: 50)
                    .foregroundStyle(.primary)
                    .background(.ultraThinMaterial)
                    .clipped()
                    .opacity(topRotation <= -90 ? 1 : 0)
            }
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray.opacity(0.4)),
                alignment: .bottom
            )
            .rotation3DEffect(.degrees(topRotation), axis: (x: 1, y: 0, z: 0), anchor: .bottom, perspective: 0.5)
            .clipped()

            // Bottom half
            ZStack {
                Text(previousDigit)
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .frame(width: 80, height: 50)
                    .foregroundStyle(.primary)
                    .background(.ultraThinMaterial)
                    .clipped()
                    .opacity(bottomRotation >= 90 ? 1 : 0)

                Text(digit)
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .frame(width: 80, height: 50)
                    .foregroundStyle(.primary)
                    .background(.ultraThinMaterial)
                    .clipped()
                    .opacity(bottomRotation < 90 ? 1 : 0)
            }
            .rotation3DEffect(.degrees(bottomRotation), axis: (x: 1, y: 0, z: 0), anchor: .top, perspective: 0.5)
            .clipped()
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .onAppear { previousDigit = digit }
        .onChange(of: digit) { _, newValue in
            // First flip the top half away
            withAnimation(.easeInOut(duration: 0.25)) {
                topRotation = -90
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                previousDigit = newValue
                topRotation = 0
                bottomRotation = 90
                // Then flip the bottom half in
                withAnimation(.easeInOut(duration: 0.25)) {
                    bottomRotation = 0
                }
            }
        }
    }
}
