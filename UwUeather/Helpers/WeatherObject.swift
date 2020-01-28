//
//  WeatherObject.swift
//  UwUeather
//
//  Created by Nick Zolnoor on 1/21/20.
//  Copyright © 2020 Nick Zolnoor. All rights reserved.
//

import Foundation

struct Weather {
    var summary: String?
    //var location: String?
}

extension Weather {
    init?(json: [String: Any]) {

        if let currently = json["currently"] as? [String: Any] {
            if let summary = currently["summary"] as? String {
                self.summary = summary
            }
        } else {
            self.summary = nil
        }
        
    }
}
