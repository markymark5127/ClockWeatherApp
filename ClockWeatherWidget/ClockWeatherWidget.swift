import WidgetKit
import SwiftUI
import Foundation
import UIKit

/// Single digit view used by the widget and mimicking the main app style.
struct WidgetSingleDigitView: View {
    let text: String
    let fontName: String
    let type: FlipType

    var body: some View {
        let width = CGFloat(40 * max(1, text.count))
        Text(text)
            .font(.custom(fontName, size: 60))
            .foregroundColor(.black)
            .frame(width: width, height: 40, alignment: type.alignment)
            .padding(type.padding, -8)
            .clipped()
            .background(Color.white)
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


/// Flip digit view used by the widget.
struct WidgetFlipDigitView: View {
    let digit: String
    let fontName: String

    @State private var previousDigit: String = ""
    @State private var animateTop = false
    @State private var animateBottom = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                WidgetSingleDigitView(text: digit, fontName: fontName, type: WidgetSingleDigitView.FlipType.bottom)
                WidgetSingleDigitView(text: previousDigit, fontName: fontName, type: WidgetSingleDigitView.FlipType.bottom)
                    .rotation3DEffect(.degrees(animateTop ? -90 : 0),
                                      axis: (x: 1, y: 0, z: 0),
                                      anchor: .bottom,
                                      perspective: 0.5)
            }
            .clipped()

        Rectangle()
            .fill(Color.gray.opacity(0.4))
            .frame(height: 1)

        ZStack {
            WidgetSingleDigitView(text: previousDigit, fontName: fontName, type: WidgetSingleDigitView.FlipType.top)
            WidgetSingleDigitView(text: digit, fontName: fontName, type: WidgetSingleDigitView.FlipType.top)
                .rotation3DEffect(.degrees(animateBottom ? 0 : 90),
                                  axis: (x: 1, y: 0, z: 0),
                                  anchor: .top,
                                  perspective: 0.5)
        }
        .clipped()
    }
    .fixedSize()
    .onAppear { previousDigit = digit }
    .onChange(of: digit) { _, newValue in
        withAnimation(.easeInOut(duration: 0.25)) {
            animateTop = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            previousDigit = newValue
            animateTop = false
            animateBottom = false
            withAnimation(.easeInOut(duration: 0.25)) {
                animateBottom = true
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
            HStack(spacing: 8) {
                WidgetFlipDigitView(digit: entry.hour, fontName: entry.fontName)
                WidgetFlipDigitView(digit: entry.minute, fontName: entry.fontName)
            }
            .frame(height: 120)

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
