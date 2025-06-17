
import Foundation
import CoreLocation
import SwiftUI
import WidgetKit

struct WeatherResponse: Decodable {
    struct CurrentWeather: Decodable {
        let temperature: Double
        let weathercode: Int
    }

    let current_weather: CurrentWeather
}

class WeatherFetcher: ObservableObject {
    @Published var temperature: String = "--"
    @Published var condition: String = "Loading..."
    @Published var city: String = "Locating..."
    @AppStorage("unit", store: UserDefaults(suiteName: "group.com.markmayne.ClockWeatherApp"))
    var unit: String = "fahrenheit"

    private var lastCoordinates: CLLocationCoordinate2D?

    let sharedDefaults = UserDefaults(suiteName: "group.com.markmayne.ClockWeatherApp")

    func fetchWeather(lat: Double, lon: Double) {
        lastCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&current_weather=true&temperature_unit=\(unit)&timezone=auto"

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let decoded = try? JSONDecoder().decode(WeatherResponse.self, from: data) else {
                DispatchQueue.main.async {
                    self.temperature = "--"
                    self.condition = "Unavailable"
                }
                return
            }

            DispatchQueue.main.async {
                let temp = "\(Int(decoded.current_weather.temperature))°"
                let desc = self.description(for: decoded.current_weather.weathercode)

                self.temperature = temp
                self.condition = desc

                self.sharedDefaults?.setValue(temp, forKey: "temperature")
                self.sharedDefaults?.setValue(desc, forKey: "condition")
                self.sharedDefaults?.setValue(self.unit, forKey: "unit")
                self.sharedDefaults?.setValue(self.lastCoordinates?.latitude, forKey: "lat")
                self.sharedDefaults?.setValue(self.lastCoordinates?.longitude, forKey: "lon")
                self.sharedDefaults?.setValue(Date(), forKey: "lastUpdated")
                WidgetCenter.shared.reloadAllTimelines()
            }
        }.resume()

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(CLLocation(latitude: lat, longitude: lon)) { placemarks, _ in
            if let city = placemarks?.first?.locality {
                DispatchQueue.main.async {
                    self.city = city
                    self.sharedDefaults?.setValue(city, forKey: "city")
                }
            }
        }
    }

    func updateCity(_ newCity: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(newCity) { placemarks, _ in
            if let loc = placemarks?.first?.location {
                self.fetchWeather(lat: loc.coordinate.latitude, lon: loc.coordinate.longitude)
            }
        }
    }

    func refresh() {
        if let coords = lastCoordinates {
            fetchWeather(lat: coords.latitude, lon: coords.longitude)
        }
    }

    private func description(for code: Int) -> String {
        switch code {
        case 0:
            return "Clear"
        case 1:
            return "Mostly Clear"
        case 2:
            return "Partly Cloudy"
        case 3:
            return "Overcast"
        case 45, 48:
            return "Fog"
        case 51, 53, 55:
            return "Drizzle"
        case 56, 57:
            return "Freezing Drizzle"
        case 61, 63, 65:
            return "Rain"
        case 66, 67:
            return "Freezing Rain"
        case 71, 73, 75, 77:
            return "Snow"
        case 80, 81, 82:
            return "Rain Showers"
        case 85, 86:
            return "Snow Showers"
        case 95, 96, 99:
            return "Thunderstorm"
        default:
            return "Unknown"
        }
    }
}
