//
//  WeatherService.swift
//  Weather App 2
//
//  Created by Meera Patel on 5/3/22.
//


import CoreLocation
import Foundation

public final class WeatherService: NSObject {

  private let locationManager = CLLocationManager()
  private let API_KEY = "31016b6257eaaa47ed16fa2751787e23"
  private var completionHandler: ((Weather?, LocationAuthError?) -> Void)?
  private var dataTask: URLSessionDataTask?

  public override init() {
    super.init()
    locationManager.delegate = self
  }

  public func loadWeatherData(
    _ completionHandler: @escaping((Weather?, LocationAuthError?) -> Void)
  ) {
    self.completionHandler = completionHandler
    loadDataOrRequestLocationAuth()
  }

  private func makeDataRequest(forCoordinates coordinates: CLLocationCoordinate2D) {
    guard let urlString =
      "https://api.openweathermap.org/data/2.5/weather?lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&appid=\(API_KEY)&units=imperial"
        .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
    guard let url = URL(string: urlString) else { return }

    dataTask?.cancel()

    dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
      guard error == nil, let data = data else { return }
  
      if let response = try? JSONDecoder().decode(APIResponse.self, from: data) {
        self.completionHandler?(Weather(response: response), nil)
      }
    }
    dataTask?.resume()
  }
  
  private func loadDataOrRequestLocationAuth() {
    switch locationManager.authorizationStatus {
    case .authorizedAlways, .authorizedWhenInUse:
      locationManager.startUpdatingLocation()
    case .denied, .restricted:
      completionHandler?(nil, LocationAuthError())
    default:
      locationManager.requestWhenInUseAuthorization()
    }
  }
}

extension WeatherService: CLLocationManagerDelegate {
  public func locationManager(
    _ manager: CLLocationManager,
    didUpdateLocations locations: [CLLocation]
  ) {
    guard let location = locations.first else { return }
    makeDataRequest(forCoordinates: location.coordinate)
  }

  public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    loadDataOrRequestLocationAuth()
  }
  public func locationManager(
    _ manager: CLLocationManager,
    didFailWithError error: Error
  ) {
    print("Something went wrong: \(error.localizedDescription)")
  }
}

struct APIResponse: Decodable {
  let name: String
  let main: APIMain
  let weather: [APIWeather]
}

struct APIMain: Decodable {
  let temp: Double
}

struct APIWeather: Decodable {
  let description: String
  let iconName: String
  
  enum CodingKeys: String, CodingKey {
    case description
    case iconName = "main"
  }
}

public struct LocationAuthError: Error {}
