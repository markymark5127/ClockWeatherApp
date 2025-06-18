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
    var textColor: Color = .white
    var backgroundColor: Color = .black

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let textSize = size.height * 2

            Text(digit)
                .font(.custom(fontName, size: textSize))
                .frame(width: size.width, height: textSize, alignment: clipTop ? .top : .bottom)
                .foregroundStyle(textColor)
                .background(backgroundColor)
                .offset(y: clipTop ? 0 : -size.height)
        }
        .clipped()
    }
}




