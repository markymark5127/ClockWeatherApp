import SwiftUI

struct FlipDigitView: View {
    let digit: String
    let fontName: String

    @State private var previousDigit: String = ""
    @State private var animateTop = false
    @State private var animateBottom = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                SingleDigitView(text: digit, fontName: fontName, type: SingleDigitView.FlipType.bottom)
                SingleDigitView(text: previousDigit, fontName: fontName, type: SingleDigitView.FlipType.bottom)
                    .rotation3DEffect(.degrees(animateTop ? -90 : 0),
                                      axis: (x: 1, y: 0, z: 0),
                                      anchor: .bottom,
                                      perspective: 0.5)
            }
            .clipped()

            Rectangle()
                .fill(Color.gray.opacity(0.4))
                .frame(height: 1)

            ZStack {
                SingleDigitView(text: previousDigit, fontName: fontName, type: SingleDigitView.FlipType.top)
                SingleDigitView(text: digit, fontName: fontName, type: SingleDigitView.FlipType.top)
                    .rotation3DEffect(.degrees(animateBottom ? 0 : 90),
                                      axis: (x: 1, y: 0, z: 0),
                                      anchor: .top,
                                      perspective: 0.5)
            }
            .clipped()
        }
        .fixedSize()
        .onAppear { previousDigit = digit }
        .onChange(of: digit) { _, newValue in
            withAnimation(.easeInOut(duration: 0.25)) {
                animateTop = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                previousDigit = newValue
                animateTop = false
                animateBottom = false
                withAnimation(.easeInOut(duration: 0.25)) {
                    animateBottom = true
                }
            }
        }
    }
}
