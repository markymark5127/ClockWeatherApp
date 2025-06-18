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

    var body: some View {
        let width = CGFloat(40 * max(1, text.count))
        let fontSize: CGFloat = 60
        let font = UIFont(name: fontName, size: fontSize) ?? .systemFont(ofSize: fontSize)
        let sample = ("8" as NSString).size(withAttributes: [.font: font])
        let offset = (40 - sample.height) / 2
        Text(text)
            .font(.custom(fontName, size: fontSize))
            .offset(y: offset)
            .foregroundColor(.white)
            .frame(width: width, height: 40, alignment: type.alignment)
            .padding(type.padding, -8)
            .clipped()
            .background(Color.black)
            .cornerRadius(4)
            .padding(type.padding, -4)
    }

    enum FlipType {
        case top
        case bottom

        var padding: Edge.Set {
            self == .top ? .bottom : .top
        }

        var alignment: Alignment {
            self == .top ? .bottom : .top
        }
    }
}
