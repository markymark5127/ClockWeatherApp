import WidgetKit
import SwiftUI

/// Simplified flip digit view for the widget. This avoids needing to share
/// sources between targets while still providing the flip animation.
struct WidgetFlipDigitView: View {
    let digit: String
    @State private var previousDigit: String = ""
    @State private var rotation: Double = 0

    var body: some View {
        Text(previousDigit)
            .font(.system(size: 36, weight: .bold, design: .rounded))
            .frame(width: 40, height: 60)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .rotation3DEffect(.degrees(rotation), axis: (x: 1, y: 0, z: 0))
            .onAppear { previousDigit = digit }
            .onChange(of: digit) { _, newValue in
                withAnimation(.easeInOut(duration: 0.25)) {
                    rotation = -90
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    previousDigit = newValue
                    rotation = 90
                    withAnimation(.easeInOut(duration: 0.25)) {
                        rotation = 0
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
}

struct ClockWeatherProvider: TimelineProvider {
    let sharedDefaults = UserDefaults(suiteName: "group.com.yourcompany.ClockWeatherApp")

    func placeholder(in context: Context) -> ClockWeatherEntry {
        let time = getCurrentTime()
        return ClockWeatherEntry(
            date: Date(),
            temperature: "72°",
            condition: "Sunny",
            city: "San Francisco",
            hour: time.hour,
            minute: time.minute
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ClockWeatherEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ClockWeatherEntry>) -> Void) {
        let time = getCurrentTime()
        let temp = sharedDefaults?.string(forKey: "temperature") ?? "--°"
        let cond = sharedDefaults?.string(forKey: "condition") ?? "Updating..."
        let city = sharedDefaults?.string(forKey: "city") ?? "Location..."

        let entry = ClockWeatherEntry(
            date: Date(),
            temperature: temp,
            condition: cond,
            city: city,
            hour: time.hour,
            minute: time.minute
        )
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    func getCurrentTime() -> (hour: String, minute: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let time = formatter.string(from: Date()).split(separator: ":")
        return (String(time[0]), String(time[1]))
    }
}

struct ClockWeatherWidgetEntryView: View {
    var entry: ClockWeatherEntry

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 6) {
                WidgetFlipDigitView(digit: entry.hour)
                WidgetFlipDigitView(digit: entry.minute)
            }

            VStack(alignment: .leading) {
                Text(entry.city).font(.caption)
                Text(entry.condition).font(.caption2)
                Text(entry.temperature).font(.title2).bold()
            }
        }
        .padding()
        .containerBackground(.ultraThinMaterial, for: .widget)
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
