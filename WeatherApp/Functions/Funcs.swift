//
//  Funcs.swift
//  WeatherApp
//
//  Created by Ahmet on 14.07.2023.
//

import Foundation

struct WeatherDataManager {
    static func getWeatherData(latitude: String, longitude: String, completion: @escaping (Empty?) -> Void) {
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?lat=\(latitude)&lon=\(longitude)&appid=6578caad0d61fb9907e3dbec68a0f41b"
        
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let weatherData = try decoder.decode(Empty.self, from: data)
                        completion(weatherData)
                    } catch {
                        print("JSON Decode Error: \(error.localizedDescription)")
                        completion(nil)
                    }
                } else if let error = error {
                    print("HTTP Request Failed: \(error)")
                    completion(nil)
                }
            }
            task.resume()
        } else {
            completion(nil)
        }
    }
}
