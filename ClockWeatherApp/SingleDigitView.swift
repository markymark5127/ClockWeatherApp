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
        let fontSize: CGFloat = height * 1.5
        let font = UIFont(name: fontName, size: fontSize) ?? .systemFont(ofSize: fontSize)
        let sample = ("8" as NSString).size(withAttributes: [.font: font])
        let offset = (height - sample.height) / 2
        Text(text)
            .font(.custom(fontName, size: fontSize))
            .offset(y: offset)
            .foregroundColor(.white)
            .frame(width: width, height: height, alignment: type.alignment)
            .padding(type.padding, -height / 5)
            .clipped()
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
