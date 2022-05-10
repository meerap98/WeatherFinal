//
//  Weather_App_2App.swift
//  Weather App 2
//
//  Created by Meera Patel on 5/3/22.
//

import SwiftUI

@main
struct WeatherApp: App {
  var body: some Scene {
    WindowGroup {
      let weatherService = WeatherService()
      WeatherView(viewModel: WeatherViewModel(weatherService: weatherService))
    }
  }
}
