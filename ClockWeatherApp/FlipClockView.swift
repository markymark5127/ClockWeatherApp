//
//  FlipClockView.swift
//  ClockWeatherApp
//
//  Created by Mark Mayne on 6/17/25.
//

import SwiftUI
import Foundation

struct FlipClockView: View {
    @State private var currentTime: (hour: String, minute: String) = ("--", "--")
    let fontName: String
    let timeFormat: String

    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(currentTime.hour.enumerated()), id: \.offset) { _, ch in
                FlipDigitView(digit: String(ch), fontName: fontName)
            }

            Text(":")
                .font(.system(size: 50, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .offset(y: -10)

            ForEach(Array(currentTime.minute.enumerated()), id: \.offset) { _, ch in
                FlipDigitView(digit: String(ch), fontName: fontName)
            }
        }
        .onAppear {
            updateTime()
        }
        .onReceive(timer) { _ in
            updateTime()
        }
    }

    private func updateTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = timeFormat == "12hr" ? "hh:mm" : "HH:mm"
        let split = formatter.string(from: Date()).split(separator: ":")
        currentTime = (String(split[0]), String(split[1]))
    }
}
