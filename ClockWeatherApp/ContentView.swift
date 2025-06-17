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
    @StateObject var locationManager = LocationManager()
    @State private var showSettings = false
    @AppStorage("timeFormat", store: UserDefaults(suiteName: "group.com.markmayne.ClockWeatherApp"))
    private var timeFormat: String = "24hr"

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                FlipDigitView(digit: time.hour)
                FlipDigitView(digit: time.minute)
            }

            GlassWeatherCard(weather: weather)
                .frame(height: 80)
                .padding(.horizontal)
            Button("Settings") { showSettings = true }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                self.time = getCurrentTime()
            }
        }
        .onChange(of: timeFormat) { _, _ in
            self.time = getCurrentTime()
        }
        .onChange(of: locationManager.location) { _, newValue in
            if let loc = newValue {
                weather.fetchWeather(lat: loc.coordinate.latitude, lon: loc.coordinate.longitude)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(weather: weather)
        }
    }
}

func getCurrentTime() -> (hour: String, minute: String) {
    let defaults = UserDefaults(suiteName: "group.com.markmayne.ClockWeatherApp")
    let format = defaults?.string(forKey: "timeFormat") ?? "24hr"
    let formatter = DateFormatter()
    formatter.dateFormat = format == "12hr" ? "hh:mm" : "HH:mm"
    let time = formatter.string(from: Date()).split(separator: ":")
    return (String(time[0]), String(time[1]))
}

