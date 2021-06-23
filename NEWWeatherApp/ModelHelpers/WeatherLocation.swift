//
//  WeatherLocation.swift
//  NEWWeatherApp
//
//  Created by Paul James on 16.06.2021.
//

import Foundation

struct WeatherLocation: Equatable, Codable {
    var city: String!
    var country: String!
    var countryCode: String!
    var isCurrentLocation: Bool!
    
}
