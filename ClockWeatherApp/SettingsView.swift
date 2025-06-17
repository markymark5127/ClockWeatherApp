import SwiftUI
import WidgetKit

struct SettingsView: View {
    @AppStorage("unit", store: UserDefaults(suiteName: "group.com.yourcompany.ClockWeatherApp"))
    private var unit: String = "fahrenheit"
    @AppStorage("timeFormat", store: UserDefaults(suiteName: "group.com.yourcompany.ClockWeatherApp"))
    private var timeFormat: String = "24hr"
    @AppStorage("locationMode", store: UserDefaults(suiteName: "group.com.yourcompany.ClockWeatherApp"))
    private var locationMode: String = "currentlocation"
    @State private var cityName: String = ""
    @ObservedObject var weather: WeatherFetcher

    var body: some View {
        NavigationStack {
            Form {
                Section("Location") {
                    Picker("Source", selection: $locationMode) {
                        Text("Current").tag("currentlocation")
                        Text("Manual").tag("manual")
                    }
                    .pickerStyle(.segmented)

                    if locationMode == "manual" {
                        TextField("City", text: $cityName)
                            .textFieldStyle(.roundedBorder)
                        Button("Update") {
                            weather.updateCity(cityName)
                        }
                    }
                }

                Section("Units") {
                    Picker("Units", selection: $unit) {
                        Text("Fahrenheit").tag("fahrenheit")
                        Text("Celsius").tag("celsius")
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: unit) { _, _ in
                        weather.unit = unit
                        weather.refresh()
                    }
                }

                Section("Clock Format") {
                    Picker("Clock Format", selection: $timeFormat) {
                        Text("24 Hour").tag("24hr")
                        Text("12 Hour").tag("12hr")
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: timeFormat) { _, _ in
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    @Environment(\.dismiss) private var dismiss
}

#Preview {
    SettingsView(weather: WeatherFetcher())
}

