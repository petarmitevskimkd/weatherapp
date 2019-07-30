//
//  ApiConfig.swift
//  weather
//
//  Created by Telekom MK on 7/22/19.
//  Copyright © 2019 petar. All rights reserved.
//

import Foundation


class ApiConfig{
    #if DEVELOPMENT
    static let apiURL = "https://www.metaweather.com"
    #elseif TEST
    static let apiURL = "https://www.metaweather.com"
    #elseif UA
    static let apiURL = "https://www.metaweather.com"
    #elseif PRODUCTION
    static let apiURL = "https://www.metaweather.com"
    #else
    static let apiURL = "https://www.metaweather.com"
    #endif
    
    
    static let dataByWOEID  = "/api/location/"
    static let imageApi = "/static/img/weather/png/"
    
}


class Config{
    static let FORMATyearMonthDay = "yyyy-MM-dd"
    static let FORMATyearMonthDayTime = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
    static let FORMATsunRiseAndSet = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSxxx"
    static let FORMATdayMontYear = "E dd MMM"
    
    
}

