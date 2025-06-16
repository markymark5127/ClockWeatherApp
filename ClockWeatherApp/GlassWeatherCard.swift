import SwiftUI

struct GlassWeatherCard: View {
    @ObservedObject var weather: WeatherFetcher

    var body: some View {
        VStack(alignment: .leading) {
            Text(weather.city).font(.caption)
            Text(weather.condition).font(.caption2)
            Text(weather.temperature).font(.title2).bold()
        }
        .padding(8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
