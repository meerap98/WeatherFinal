//
//  WeatherViewModel.swift
//  Weather App 2
//
//  Created by Meera Patel on 5/3/22.
//

import Foundation

private let defaultIcon = "β"
private let iconMap = [
  "Drizzle" : "π§",
  "Thunderstorm" : "β",
  "Rain": "π¦",
  "Snow": "βοΈ",
  "Clear": "βοΈ",
  "Clouds" : "βοΈ",
  "Haze": "π¨",
  
]

class WeatherViewModel: ObservableObject {
  @Published var cityName: String = "City Name"
  @Published var temperature: String = "--"
  @Published var weatherDescription: String = "--"
  @Published var weatherIcon: String = defaultIcon
  @Published var shouldShowLocationError: Bool = false

  public let weatherService: WeatherService

  init(weatherService: WeatherService) {
    self.weatherService = weatherService
  }

  func refresh() {
    weatherService.loadWeatherData { weather, error in
      DispatchQueue.main.async {
        if let _ = error {
          self.shouldShowLocationError = true
          return
        }

        self.shouldShowLocationError = false
        guard let weather = weather else { return }
        self.cityName = weather.city
        self.temperature = "\(weather.temperature)ΒΊF"
        self.weatherDescription = weather.description.capitalized
        self.weatherIcon = iconMap[weather.iconName] ?? defaultIcon
      }
    }
  }
}

