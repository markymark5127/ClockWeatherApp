//
//  ContentView.swift
//  ClockWeatherApp
//
//  Created by Mark Mayne on 6/16/25.
//

import SwiftUI
import CoreLocation
import WidgetKit

struct ContentView: View {
    @State private var time = getCurrentTime()
    @StateObject var weather = WeatherFetcher()

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                FlipDigitView(digit: time.hour)
                FlipDigitView(digit: time.minute)
            }

            GlassWeatherCard(weather: weather)
                .frame(height: 80)
                .padding(.horizontal)
        }
        .onAppear {
            requestLocation(weather: weather)
            Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                self.time = getCurrentTime()
            }
        }
    }
}

func getCurrentTime() -> (hour: String, minute: String) {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    let time = formatter.string(from: Date()).split(separator: ":")
    return (String(time[0]), String(time[1]))
}

func requestLocation(weather: WeatherFetcher) {
    let manager = CLLocationManager()
    if Bundle.main.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription") != nil {
        manager.requestWhenInUseAuthorization()
    }
    if let location = manager.location {
        let coords = location.coordinate
        weather.fetchWeather(lat: coords.latitude, lon: coords.longitude)
    }
}
