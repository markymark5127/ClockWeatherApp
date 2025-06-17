import SwiftUI

struct FlipDigitView: View {
    let digit: String
    let fontName: String

    @State private var previousDigit: String = ""
    @State private var topRotation: Double = 0
    @State private var bottomRotation: Double = 0

    var body: some View {
        GeometryReader { geo in
            let halfHeight = geo.size.height / 2
            let width = geo.size.width

            VStack(spacing: 0) {
                ZStack {
                    DigitHalfView(digit: previousDigit, fontName: fontName, clipTop: true)
                    DigitHalfView(digit: digit, fontName: fontName, clipTop: true)
                        .rotation3DEffect(.degrees(topRotation), axis: (x: 1, y: 0, z: 0), anchor: .bottom, perspective: 0.5)
                        .opacity(topRotation != 0 ? 1 : 0)
                }
                .frame(width: width, height: halfHeight)

                ZStack {
                    DigitHalfView(digit: digit, fontName: fontName, clipTop: false)
                        .opacity(bottomRotation == 0 ? 1 : 0)
                    DigitHalfView(digit: previousDigit, fontName: fontName, clipTop: false)
                        .rotation3DEffect(.degrees(bottomRotation), axis: (x: 1, y: 0, z: 0), anchor: .top, perspective: 0.5)
                        .opacity(bottomRotation != 0 ? 1 : 0)
                }
                .frame(width: width, height: halfHeight)
            }
            .frame(width: width, height: geo.size.height)
        }
        .aspectRatio(0.6, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
        .onAppear { previousDigit = digit }
        .onChange(of: digit) { _, newDigit in
            withAnimation(.easeInOut(duration: 0.25)) {
                topRotation = -90
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                previousDigit = newDigit
                topRotation = 0
                bottomRotation = 90
                withAnimation(.easeInOut(duration: 0.25)) {
                    bottomRotation = 0
                }
            }
        }
    }
}
