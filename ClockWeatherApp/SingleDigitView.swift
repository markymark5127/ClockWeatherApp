//
//  SingleDigitView.swift
//  ClockWeatherApp
//
//  Created by Mark Mayne on 6/17/25.
//


struct SingleDigitView: View {
    let text: String
    let fontName: String
    let type: FlipType

    var body: some View {
        Text(text)
            .font(.custom(fontName, size: 60))
            .foregroundColor(.white)
            .frame(width: 40, height: 40, alignment: type.alignment)
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
