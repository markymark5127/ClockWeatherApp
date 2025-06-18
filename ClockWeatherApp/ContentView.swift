//
//  ContentView.swift
//  ClockWeatherApp
//
//  Created by Mark Mayne on 6/16/25.
//

import SwiftUI
import CoreLocation
import WidgetKit
import UIKit

struct ContentView: View {
    @State private var time: (hour: String, minute: String) = ("--", "--")
    @StateObject var weather = WeatherFetcher()
    @StateObject var locationManager = LocationManager()
    @State private var showSettings = false
    @AppStorage("timeFormat", store: UserDefaults(suiteName: "group.com.markmayne.ClockWeatherApp"))
    private var timeFormat: String = "24hr"
    @AppStorage("locationMode", store: UserDefaults(suiteName: "group.com.markmayne.ClockWeatherApp"))
    private var locationMode: String = "currentlocation"
    @AppStorage("fontName", store: UserDefaults(suiteName: "group.com.markmayne.ClockWeatherApp"))
    private var fontName: String = UIFont.systemFont(ofSize: 17).familyName

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                FlipClockView(fontName: fontName, timeFormat: timeFormat, digitHeight: 80)
            }

            GlassWeatherCard(weather: weather)
                .frame(height: 80)
                .padding(.horizontal)
            Button("Settings") { showSettings = true }
        }
        .onAppear {
            self.time = getCurrentTime()
            // Refresh every second to keep the display in sync with the system clock
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                self.time = getCurrentTime()
            }
        }
        .onChange(of: timeFormat) { _, _ in
            self.time = getCurrentTime()
        }
        .onChange(of: locationManager.location) { _, newValue in
            if locationMode == "currentlocation", let loc = newValue {
                weather.fetchWeather(lat: loc.coordinate.latitude, lon: loc.coordinate.longitude)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(weather: weather)
        }
    }
}

func getCurrentTime() -> (hour: String, minute: String) {
    var format = "24hr"
    if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" {
        if let defaults = UserDefaults(suiteName: "group.com.markmayne.ClockWeatherApp") {
            format = defaults.string(forKey: "timeFormat") ?? "24hr"
        } else {
            print("❌ Couldn't load shared UserDefaults")
        }
    }
    let formatter = DateFormatter()
    formatter.dateFormat = format == "12hr" ? "hh:mm" : "HH:mm"
    let time = formatter.string(from: Date()).split(separator: ":")
    return (String(time[0]), String(time[1]))
}

