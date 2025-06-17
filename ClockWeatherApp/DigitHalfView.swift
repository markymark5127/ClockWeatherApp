//
//  DigitHalfView.swift
//  ClockWeatherApp
//
//  Created by Mark Mayne on 6/17/25.
//
import SwiftUI

struct DigitHalfView: View {
    let digit: String
    let fontName: String
    let clipTop: Bool

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let halfHeight = size.height / 2

            Text(digit)
                .font(.custom(fontName, size: size.height * 1.5))
                .foregroundStyle(.white)
                .frame(width: size.width, height: size.height)
                .lineLimit(1)
                .minimumScaleFactor(0.1)
                .background(Color.black)
                .mask(
                    Rectangle()
                        .frame(width: size.width, height: halfHeight)
                        .offset(y: clipTop ? -halfHeight / 2 : halfHeight / 2)
                )
        }
        .clipped()
    }
}
