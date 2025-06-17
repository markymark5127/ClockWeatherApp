import SwiftUI
import UIKit

struct GlassWeatherCard: View {
    @ObservedObject var weather: WeatherFetcher
    @AppStorage("fontName", store: UserDefaults(suiteName: "group.com.markmayne.ClockWeatherApp"))
    private var fontName: String = UIFont.systemFont(ofSize: 17).familyName

    var body: some View {
        VStack(alignment: .leading) {
            Text(weather.city).font(.custom(fontName, size: UIFont.preferredFont(forTextStyle: .caption1).pointSize))
            Text(weather.condition).font(.custom(fontName, size: UIFont.preferredFont(forTextStyle: .caption2).pointSize))
            Text(weather.temperature).font(.custom(fontName, size: UIFont.preferredFont(forTextStyle: .title2).pointSize)).bold()
        }
        .padding(8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
