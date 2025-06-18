//
//  SingleDigitView.swift
//  ClockWeatherApp
//
//  Created by Mark Mayne on 6/17/25.
//

import SwiftUI
import UIKit

struct SingleDigitView: View {
    let text: String
    let fontName: String
    let type: FlipType
    var height: CGFloat = 40

    var body: some View {
        let width = CGFloat(height * max(1, text.count))
        DigitHalfView(digit: text, fontName: fontName, clipTop: type == .top)
            .frame(width: width, height: height)
            .background(Color.black)
            .cornerRadius(height / 5)
            .padding(type.padding, -height / 10)
    }

    enum FlipType {
        case top
        case bottom

        var padding: Edge.Set {
            self == .top ? .bottom : .top
        }

        var alignment: Alignment {
            self == .top ? .top : .bottom
        }
    }
}
