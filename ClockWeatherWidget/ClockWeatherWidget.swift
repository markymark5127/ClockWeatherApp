import WidgetKit
import SwiftUI
import Foundation
import UIKit

/// Flip digit view for the widget that mirrors the design used in the main app.

struct WidgetDigitHalfView: View {
    let digit: String
    let fontName: String
    let clipTop: Bool

    var body: some View {
        GeometryReader { geo in
            let height = geo.size.height
            let width = geo.size.width
            let halfHeight = height / 2

            ZStack(alignment: .top) {
                Text(digit)
                    .font(.custom(fontName, size: height * 1.4))
                    .frame(width: width, height: height * 1.4)
                    .minimumScaleFactor(0.1)
                    .lineLimit(1)
                    .foregroundStyle(.white)
                    .background(Color.black)
            }
            .frame(width: width, height: halfHeight, alignment: clipTop ? .top : .bottom)
            .clipped()
        }
    }
}








/// Flip digit view used by the widget.
struct WidgetFlipDigitView: View {
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
                    WidgetDigitHalfView(digit: previousDigit, fontName: fontName, clipTop: true)
                    WidgetDigitHalfView(digit: digit, fontName: fontName, clipTop: true)
                        .rotation3DEffect(.degrees(topRotation), axis: (x: 1, y: 0, z: 0), anchor: .bottom, perspective: 0.5)
                        .opacity(topRotation != 0 ? 1 : 0)
                }
                .frame(width: width, height: halfHeight)

                ZStack {
                    WidgetDigitHalfView(digit: digit, fontName: fontName, clipTop: false)
                        .opacity(bottomRotation == 0 ? 1 : 0)
                    WidgetDigitHalfView(digit: previousDigit, fontName: fontName, clipTop: false)
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
        .onChange(of: digit) { _, newValue in
            withAnimation(.easeInOut(duration: 0.25)) {
                topRotation = -90
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                previousDigit = newValue
                topRotation = 0
                bottomRotation = 90
                withAnimation(.easeInOut(duration: 0.25)) {
                    bottomRotation = 0
                }
            }
        }
    }
}

struct ClockWeatherEntry: TimelineEntry {
    let date: Date
    let temperature: String
    let condition: String
    let city: String
    let hour: String
    let minute: String
    let fontName: String
}

struct ClockWeatherProvider: TimelineProvider {

    private func sharedDefaults() -> UserDefaults? {
        guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else { return nil }
        return UserDefaults(suiteName: "group.com.markmayne.ClockWeatherApp")
    }

    func placeholder(in context: Context) -> ClockWeatherEntry {
        let time = getCurrentTime()
        return ClockWeatherEntry(
            date: Date(),
            temperature: "72°",
            condition: "Sunny",
            city: "San Francisco",
            hour: time.hour,
            minute: time.minute,
            fontName: UIFont.systemFont(ofSize: 17).familyName
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ClockWeatherEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ClockWeatherEntry>) -> Void) {
        let time = getCurrentTime()
        let defaults = sharedDefaults()
        let temp = defaults?.string(forKey: "temperature") ?? "--°"
        let cond = defaults?.string(forKey: "condition") ?? "Updating..."
        let city = defaults?.string(forKey: "city") ?? "Location..."
        let font = defaults?.string(forKey: "fontName") ?? UIFont.systemFont(ofSize: 17).familyName

        let entry = ClockWeatherEntry(
            date: Date(),
            temperature: temp,
            condition: cond,
            city: city,
            hour: time.hour,
            minute: time.minute,
            fontName: font
        )
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    func getCurrentTime() -> (hour: String, minute: String) {
        let defaults = sharedDefaults()
        let format = defaults?.string(forKey: "timeFormat") ?? "24hr"
        let formatter = DateFormatter()
        formatter.dateFormat = format == "12hr" ? "hh:mm" : "HH:mm"
        let time = formatter.string(from: Date()).split(separator: ":")
        return (String(time[0]), String(time[1]))
    }
}

struct ClockWeatherWidgetEntryView: View {
    var entry: ClockWeatherEntry

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 6) {
                ForEach(Array(entry.hour.map { String($0) }), id: \.self) { digit in
                    WidgetFlipDigitView(digit: digit, fontName: entry.fontName)
                }

                Text(":")
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                    .offset(y: -8)

                ForEach(Array(entry.minute.map { String($0) }), id: \.self) { digit in
                    WidgetFlipDigitView(digit: digit, fontName: entry.fontName)
                }
            }

            VStack(alignment: .leading) {
                Text(entry.city).font(.custom(entry.fontName, size: UIFont.preferredFont(forTextStyle: .caption1).pointSize))
                Text(entry.condition).font(.custom(entry.fontName, size: UIFont.preferredFont(forTextStyle: .caption2).pointSize))
                Text(entry.temperature).font(.custom(entry.fontName, size: UIFont.preferredFont(forTextStyle: .title2).pointSize)).bold()
            }
        }
        .padding()
        .containerBackground(Color.clear, for: .widget)
    }
}

struct ClockWeatherWidget: Widget {
    let kind: String = "ClockWeatherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ClockWeatherProvider()) { entry in
            ClockWeatherWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Flip Clock + Weather")
        .description("See the current time and weather at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
