import WidgetKit
import SwiftUI
import Foundation
import UIKit

/// View that clips either the top or bottom half of the provided digit.
private struct WidgetDigitHalfView: View {
    let digit: String
    let fontName: String
    let clipTop: Bool

    @Environment(\.widgetRenderingMode) private var renderingMode

    private var textStyle: Color {
        switch renderingMode {
        case .fullColor:
            return .black
        default:
            return .primary
        }
    }

    private var backgroundStyle: AnyShapeStyle {
        switch renderingMode {
        case .fullColor:
            return AnyShapeStyle(Color.white)
        default:
            return AnyShapeStyle(.ultraThinMaterial)
        }
    }

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let textSize = size.height * 2

            Text(digit)
                .font(.custom(fontName, size: textSize))
                .frame(width: size.width, height: textSize, alignment: clipTop ? .top : .bottom)
                .fixedSize()
                .foregroundStyle(textStyle)
                .background(backgroundStyle)
                .offset(y: clipTop ? 0 : -size.height)
        }
        .clipped()
    }
}

/// Single digit view used by the widget and mimicking the main app style.
struct WidgetSingleDigitView: View {
    let text: String
    let fontName: String
    let type: FlipType
    var height: CGFloat = 40

    @Environment(\.widgetRenderingMode) private var renderingMode

    private var backgroundStyle: AnyShapeStyle {
        switch renderingMode {
        case .fullColor:
            return AnyShapeStyle(Color.white)
        default:
            return AnyShapeStyle(.ultraThinMaterial)
        }
    }

    var body: some View {
        let width = height * CGFloat(max(1, text.count))
        WidgetDigitHalfView(digit: text, fontName: fontName, clipTop: type == .top)
            .frame(width: width, height: height)
            .background(backgroundStyle)
            .clipShape(RoundedCorners(radius: height / 5,
                                     corners: type == .top ? [.topLeft, .topRight] : [.bottomLeft, .bottomRight]))
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


/// Flip digit view used by the widget.
struct WidgetFlipDigitView: View {
    let digit: String
    let fontName: String
    var height: CGFloat = 40

    @State private var previousDigit: String = ""
    @State private var animateTop = false
    @State private var animateBottom = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                WidgetSingleDigitView(text: digit, fontName: fontName, type: WidgetSingleDigitView.FlipType.top, height: height)
                WidgetSingleDigitView(text: previousDigit, fontName: fontName, type: WidgetSingleDigitView.FlipType.top, height: height)
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
            WidgetSingleDigitView(text: previousDigit, fontName: fontName, type: WidgetSingleDigitView.FlipType.bottom, height: height)
            WidgetSingleDigitView(text: digit, fontName: fontName, type: WidgetSingleDigitView.FlipType.bottom, height: height)
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
    let iconName: String
    let highTemp: String
    let lowTemp: String
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
            iconName: "sun.max",
            highTemp: "75°",
            lowTemp: "55°",
            hour: time.hour,
            minute: time.minute,
            fontName: UIFont.systemFont(ofSize: 17).familyName
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ClockWeatherEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ClockWeatherEntry>) -> Void) {
        let defaults = sharedDefaults()
        let temp = defaults?.string(forKey: "temperature") ?? "--°"
        let cond = defaults?.string(forKey: "condition") ?? "Updating..."
        let city = defaults?.string(forKey: "city") ?? "Location..."
        let icon = defaults?.string(forKey: "iconName") ?? {
            if let code = defaults?.integer(forKey: "weathercode") as Int? {
                return Self.iconName(for: code)
            }
            return "questionmark"
        }()
        let high = defaults?.string(forKey: "highTemp") ?? "--"
        let low = defaults?.string(forKey: "lowTemp") ?? "--"
        let font = defaults?.string(forKey: "fontName") ?? UIFont.systemFont(ofSize: 17).familyName

        var entries: [ClockWeatherEntry] = []
        let now = Date()
        var currentDate = Calendar.current.date(bySetting: .second, value: 0, of: now) ?? now
        if currentDate <= now {
            currentDate = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!
        }
        for offset in 0..<60 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: offset, to: currentDate)!
            let time = getCurrentTime(for: entryDate)
            entries.append(
                ClockWeatherEntry(
                    date: entryDate,
                    temperature: temp,
                    condition: cond,
                    city: city,
                    iconName: icon,
                    highTemp: high,
                    lowTemp: low,
                    hour: time.hour,
                    minute: time.minute,
                    fontName: font
                )
            )
        }

        let policyDate = Calendar.current.date(byAdding: .minute, value: 60, to: currentDate)!
        completion(Timeline(entries: entries, policy: .after(policyDate)))
    }

    func getCurrentTime(for date: Date = Date()) -> (hour: String, minute: String) {
        let defaults = sharedDefaults()
        let format = defaults?.string(forKey: "timeFormat") ?? "24hr"
        let formatter = DateFormatter()
        formatter.dateFormat = format == "12hr" ? "hh:mm" : "HH:mm"
        let time = formatter.string(from: date).split(separator: ":")
        return (String(time[0]), String(time[1]))
    }

    static func iconName(for code: Int) -> String {
        switch code {
        case 0, 1:
            return "sun.max"
        case 2:
            return "cloud.sun"
        case 3:
            return "cloud"
        case 45, 48:
            return "cloud.fog"
        case 51, 53, 55:
            return "cloud.drizzle"
        case 56, 57:
            return "cloud.sleet"
        case 61, 63, 65:
            return "cloud.rain"
        case 66, 67:
            return "cloud.sleet"
        case 71, 73, 75, 77:
            return "cloud.snow"
        case 80, 81, 82:
            return "cloud.heavyrain"
        case 85, 86:
            return "cloud.snow"
        case 95, 96, 99:
            return "cloud.bolt"
        default:
            return "questionmark"
        }
    }
}

struct ClockWeatherWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    var entry: ClockWeatherEntry

    var body: some View {
        let digitHeight: CGFloat = {
            switch family {
            case .systemLarge, .systemExtraLarge:
                return 80
            default:
                return 40
            }
        }()

        Group {
            if family == .systemExtraLarge {
                GeometryReader { geo in
                    let h = geo.size.height
                    let largeDigit = h * 0.35

                    VStack(spacing: 12) {
                        Spacer(minLength: 0)
                        HStack(spacing: 8) {
                            WidgetFlipDigitView(digit: entry.hour, fontName: entry.fontName, height: largeDigit)
                            WidgetFlipDigitView(digit: entry.minute, fontName: entry.fontName, height: largeDigit)
                        }
                        .frame(height: largeDigit * 2)
                        Spacer(minLength: 0)
                        weatherInfo
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        WidgetFlipDigitView(digit: entry.hour, fontName: entry.fontName, height: digitHeight)
                        WidgetFlipDigitView(digit: entry.minute, fontName: entry.fontName, height: digitHeight)
                    }
                    .frame(height: digitHeight * 2)

                    weatherInfo
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .containerBackground(.ultraThinMaterial, for: .widget)
    }

    private var weatherInfo: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(entry.city)
                    .font(.custom(entry.fontName, size: UIFont.preferredFont(forTextStyle: .caption1).pointSize))
                Text(entry.condition)
                    .font(.custom(entry.fontName, size: UIFont.preferredFont(forTextStyle: .caption2).pointSize))
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(entry.date, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                    .font(.custom(entry.fontName, size: UIFont.preferredFont(forTextStyle: .caption1).pointSize))
                HStack(alignment: .center, spacing: 4) {
                    Text(entry.temperature)
                        .font(.custom(entry.fontName, size: UIFont.preferredFont(forTextStyle: .title2).pointSize))
                        .bold()
                    VStack(alignment: .leading, spacing: 0) {
                        Text("H: \(entry.highTemp)")
                        Text("L: \(entry.lowTemp)")
                    }
                    .font(.custom(entry.fontName, size: UIFont.preferredFont(forTextStyle: .caption2).pointSize))
                }
            }
        }
        .overlay(
            Image(systemName: entry.iconName)
                .resizable()
                .scaledToFit()
                .frame(height: 24),
            alignment: .center
        )
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
        .supportedFamilies([.systemMedium, .systemLarge, .systemExtraLarge])
    }
}
