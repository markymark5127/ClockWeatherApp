import SwiftUI

struct SettingsView: View {
    @AppStorage("unit") private var unit: String = "fahrenheit"
    @State private var cityName: String = ""
    @ObservedObject var weather: WeatherFetcher

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Location")) {
                    TextField("City", text: $cityName)
                    Button("Update") {
                        weather.updateCity(cityName)
                    }
                }

                Section(header: Text("Units")) {
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
            }
            .navigationTitle("Settings")
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

