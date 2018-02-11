//
//  WeatherData.swift
//  Skyfall
//
//  Created by Haven Barnes on 2/10/18.
//  Copyright © 2018 Azing. All rights reserved.
//

import Foundation

enum Summary: String {
    case clearDay = "clear-day"
    case clearNight = "clear-night"
    case rain = "rain"
    case snow = "snow"
    case sleet = "sleet"
    case wind = "wind"
    case fog = "fog"
    case cloudy = "cloudy"
    case partlyCloudyDay = "partly-cloudy-day"
    case partlyCloudyNight = "partly-cloudy-night"
}

struct WeatherData {
    
    var summary: Summary
    
}
