import WidgetKit
import SwiftUI
import Foundation
import UIKit

/// Simplified flip digit view for the widget. This avoids needing to share
/// sources between targets while still providing the flip animation.
struct WidgetFlipDigitView: View {
    let digit: String
    let fontName: String
    @State private var previousDigit: String = ""
    @State private var topRotation: Double = 0
    @State private var bottomRotation: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            // Top half
            ZStack {
                Text(previousDigit)
                    .font(.custom(fontName, size: 60))
                    .frame(width: 40, height: 30)
                    .foregroundStyle(.primary)
                    .background(.ultraThinMaterial)
                    .clipped()

                Text(digit)
                    .font(.custom(fontName, size: 60))
                    .frame(width: 40, height: 30)
                    .foregroundStyle(.primary)
                    .background(.ultraThinMaterial)
                    .clipped()
                    .opacity(topRotation <= -90 ? 1 : 0)
            }
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray.opacity(0.4)),
                alignment: .bottom
            )
            .rotation3DEffect(.degrees(topRotation), axis: (x: 1, y: 0, z: 0), anchor: .bottom, perspective: 0.5)
            .clipped()

            // Bottom half
            ZStack {
                Text(previousDigit)
                    .font(.custom(fontName, size: 60))
                    .frame(width: 40, height: 30)
                    .foregroundStyle(.primary)
                    .background(.ultraThinMaterial)
                    .clipped()
                    .opacity(bottomRotation >= 90 ? 1 : 0)

                Text(digit)
                    .font(.custom(fontName, size: 60))
                    .frame(width: 40, height: 30)
                    .foregroundStyle(.primary)
                    .background(.ultraThinMaterial)
                    .clipped()
                    .opacity(bottomRotation < 90 ? 1 : 0)
            }
            .rotation3DEffect(.degrees(bottomRotation), axis: (x: 1, y: 0, z: 0), anchor: .top, perspective: 0.5)
            .clipped()
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
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
                WidgetFlipDigitView(digit: entry.hour, fontName: entry.fontName)
                WidgetFlipDigitView(digit: entry.minute, fontName: entry.fontName)
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
