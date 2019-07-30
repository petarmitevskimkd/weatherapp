//
//  OfflineDB.swift
//  weather
//
//  Created by Telekom MK on 7/29/19.
//  Copyright © 2019 petar. All rights reserved.
//

import Foundation

class OfflineDB{
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    static let store = OfflineDB()
    
    init(){}
    
    func encode(_ encodable: Weather) -> String{
        do{
        let data = try encoder.encode(encodable)
        return String(data: data, encoding: .utf8)!
        }catch{
            return String()
        }
    }
    
    func decode(_ decodable: String) -> Weather{
        do{
            let data = Data(decodable.utf8)
            let weather = try decoder.decode(Weather.self, from: data)
         return weather
        }catch{
            return Weather()
        }
    }
    
    func save(_ key: String, _ value: String){
        UserDefaults.standard.set(value, forKey: key)
    }
    
    func load(_ key: String) -> String?{
        guard let value = UserDefaults.standard.object(forKey: key) else {return nil}
        return value as? String
    }
}

