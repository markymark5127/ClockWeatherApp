//
//  DigitHalfView.swift
//  ClockWeatherApp
//
//  Created by Mark Mayne on 6/17/25.
//
import SwiftUI

import SwiftUI

struct DigitHalfView: View {
    let digit: String
    let fontName: String
    let clipTop: Bool

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let halfHeight = size.height / 2

            ZStack {
                Text(digit)
                    .font(.custom(fontName, size: size.height * 1.5))
                    .frame(width: size.width, height: size.height)
                    .foregroundStyle(.white)
                    .background(Color.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .clipped()
            }
            .mask(
                VStack(spacing: 0) {
                    if clipTop {
                        Rectangle().frame(height: halfHeight)
                        Color.clear.frame(height: halfHeight)
                    } else {
                        Color.clear.frame(height: halfHeight)
                        Rectangle().frame(height: halfHeight)
                    }
                }
            )
        }
        .clipped()
    }
}




