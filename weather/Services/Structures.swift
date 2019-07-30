//
//  Structures.swift
//  weather
//
//  Created by Telekom MK on 7/22/19.
//  Copyright © 2019 petar. All rights reserved.
//

import Foundation
import Alamofire

struct Weather: Codable, Equatable{
    
    var consolidated_weather: [ConsolidatedWeatherElement]?
    var time: String?
    var sun_rise: String?
    var sun_set: String?
    var timezone_name: String?
    var parent: Parent?
    var sources: [Source]?
    var title: String?
    var location_type: String?
    var woeid: Int?
    var latt_long: String?
    var timezone: String?
    
    static func == (lhs: Weather, rhs: Weather) -> Bool {
        return lhs.woeid == rhs.woeid
    }
}

struct ConsolidatedWeatherElement: Codable{
    var id: Int!
    var weather_state_name: String?
    var weather_state_abbr: String?
    var wind_direction_compass: String?
    var created: String?
    var applicable_date: String?
    var min_temp: Double?
    var max_temp: Double?
    var the_temp: Double?
    var wind_speed: Double?
    var wind_direction: Double?
    var air_pressure: Double?
    var humidity: Int?
    var visibility: Double?
    var predictability: Int?
}

struct Parent: Codable{
    var title: String?
    var location_type: String?
    var woeid: Int?
    var latt_long: String?
}

struct Source: Codable{
    var title: String?
    var slug: String?
    var url: String?
    var crawl_rate: Int?
}
