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

    // Update every second so the minute flips exactly when the system clock changes
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 8) {
            FlipDigitView(digit: currentTime.hour, fontName: fontName)
            FlipDigitView(digit: currentTime.minute, fontName: fontName)
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
