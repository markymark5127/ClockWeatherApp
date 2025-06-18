
import Foundation
import CoreLocation
import SwiftUI
import WidgetKit

struct WeatherResponse: Decodable {
    struct CurrentWeather: Decodable {
        let temperature: Double
        let weathercode: Int
    }
    struct Daily: Decodable {
        let temperature_2m_max: [Double]
        let temperature_2m_min: [Double]
    }

    let current_weather: CurrentWeather
    let daily: Daily?
}

class WeatherFetcher: ObservableObject {
    @Published var temperature: String = "--"
    @Published var condition: String = "Loading..."
    @Published var city: String = "Locating..."
    @Published var highTemp: String = "--"
    @Published var lowTemp: String = "--"
    @AppStorage("unit", store: UserDefaults(suiteName: "group.com.markmayne.ClockWeatherApp"))
    var unit: String = "fahrenheit"

    private var lastCoordinates: CLLocationCoordinate2D?

    private func sharedDefaults() -> UserDefaults? {
        guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else { return nil }
        return UserDefaults(suiteName: "group.com.markmayne.ClockWeatherApp")
    }

    func fetchWeather(lat: Double, lon: Double) {
        lastCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&current_weather=true&daily=temperature_2m_max,temperature_2m_min&temperature_unit=\(unit)&timezone=auto"

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let decoded = try? JSONDecoder().decode(WeatherResponse.self, from: data) else {
                DispatchQueue.main.async {
                    self.temperature = "--"
                    self.condition = "Unavailable"
                    self.highTemp = "--"
                    self.lowTemp = "--"
                }
                return
            }

            DispatchQueue.main.async {
                let temp = "\(Int(decoded.current_weather.temperature))°"
                let desc = self.description(for: decoded.current_weather.weathercode)

                self.temperature = temp
                self.condition = desc

                if let daily = decoded.daily {
                    self.highTemp = "\(Int(daily.temperature_2m_max.first ?? 0))°"
                    self.lowTemp = "\(Int(daily.temperature_2m_min.first ?? 0))°"
                }

                let defaults = self.sharedDefaults()
                defaults?.setValue(temp, forKey: "temperature")
                defaults?.setValue(desc, forKey: "condition")
                defaults?.setValue(decoded.current_weather.weathercode, forKey: "weathercode")
                defaults?.setValue(self.iconName(for: decoded.current_weather.weathercode), forKey: "iconName")
                defaults?.setValue(self.highTemp, forKey: "highTemp")
                defaults?.setValue(self.lowTemp, forKey: "lowTemp")
                defaults?.setValue(self.unit, forKey: "unit")
                defaults?.setValue(self.lastCoordinates?.latitude, forKey: "lat")
                defaults?.setValue(self.lastCoordinates?.longitude, forKey: "lon")
                defaults?.setValue(Date(), forKey: "lastUpdated")
                WidgetCenter.shared.reloadAllTimelines()
            }
        }.resume()

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(CLLocation(latitude: lat, longitude: lon)) { placemarks, _ in
            if let city = placemarks?.first?.locality {
                DispatchQueue.main.async {
                    self.city = city
                    self.sharedDefaults()?.setValue(city, forKey: "city")
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

    func iconName(for code: Int) -> String {
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
