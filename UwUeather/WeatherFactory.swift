//
//  WeatherFactory.swift
//  UwUeather
//
//  Created by Nick Zolnoor on 11/1/19.
//  Copyright © 2019 Nick Zolnoor. All rights reserved.
//

import Foundation
import CoreLocation

class WeatherFactory {
    private let darkSkySecret = Secrets.darkApiKey
    private let darkSkyForecastBaseURL = "https://api.darksky.net/forecast/"
    private var dataString: String?
    
    func getWeather(for coord: CLLocationCoordinate2D, completion: @escaping (Weather?, Error?) -> Void) {
        var weather: Weather?
        let session = URLSession.shared
        
        let urlString = "\(darkSkyForecastBaseURL)\(darkSkySecret)/\(coord.latitude),\(coord.longitude)"
        print(urlString)
        if let weatherRequest = URL(string: urlString) {
            let dataTask = session.dataTask(with: weatherRequest) { (data, response, error) in
                if let error = error {
                    completion(nil, error)
                }
                else if let data = data {
                    //print("data before converting to json: \(data)")
                    if let json = try? JSONSerialization.jsonObject(with: data, options: []){
                        print("convert to json before dict: \(json)")
                        if let jsonDict = json as? [String: Any] {
                            weather = Weather(json: jsonDict)
                            completion(weather, nil)
                        }
                    }
                }
            }
            dataTask.resume()
        }
    }
}
