
import Foundation
import CoreLocation

struct WeatherResponse: Decodable {
    let main: Main
    let weather: [Weather]
    let name: String
}

struct Main: Decodable {
    let temp: Double
}

struct Weather: Decodable {
    let description: String
    let icon: String
}

class WeatherFetcher: ObservableObject {
    @Published var temperature: String = "--"
    @Published var condition: String = "Loading..."
    @Published var city: String = "Locating..."

    let sharedDefaults = UserDefaults(suiteName: "group.com.yourcompany.ClockWeatherApp")

    func fetchWeather(lat: Double, lon: Double) {
        let apiKey = "YOUR_API_KEY"
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=imperial"

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                if let decoded = try? JSONDecoder().decode(WeatherResponse.self, from: data) {
                    DispatchQueue.main.async {
                        let temp = "\(Int(decoded.main.temp))°"
                        let desc = decoded.weather.first?.description.capitalized ?? "Unknown"
                        let name = decoded.name

                        self.temperature = temp
                        self.condition = desc
                        self.city = name

                        self.sharedDefaults?.setValue(temp, forKey: "temperature")
                        self.sharedDefaults?.setValue(desc, forKey: "condition")
                        self.sharedDefaults?.setValue(name, forKey: "city")
                        self.sharedDefaults?.setValue(Date(), forKey: "lastUpdated")
                    }
                }
            }
        }.resume()
    }
}
