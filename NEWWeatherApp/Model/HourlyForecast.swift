//
//  HourlyForecast.swift
//  NEWWeatherApp
//
//  Created by Paul James on 12.06.2021.
//

import Foundation
import Alamofire
import SwiftyJSON


class HourlyForecast {
    
    private var _date: Date!
    private var _temp: Double!
    private var _weatherIcon: String!
    
    
    var date: Date{
        if _date == nil {
            _date = Date()
        }
        return _date
    }
    
    var temp: Double {
        if _temp == nil {
            _temp = 0
        }
        return _temp
    }
    
    var weatherIcon: String {
        if _weatherIcon == nil {
            _weatherIcon = ""
        }
        return _weatherIcon
    }
    
    init(weatherDictionary: Dictionary<String, AnyObject>) {
        let json = JSON(weatherDictionary)
        
        self._temp = getTempBasedOnSetting(celsius: json["temp"].double ?? 0.0)
        self._date = currentDateFromUnix(unixDate: json["ts"].double!)
        self._weatherIcon = json["weather"]["icon"].stringValue
    }
    
    
    class func downloadDailyForecastWeather(location: WeatherLocation, completion: @escaping(_ hourlyForcast:[HourlyForecast]) -> Void) {
//        let HOURLYFORECAST_URL = "https://api.weatherbit.io/v2.0/forecast/hourly?lat=59.9386&lon=30.3141&key=cff8edafa3ea41059a4e21a29483afe7"
        
        var HOURLYFORECAST_URL: String!
        
        if !location.isCurrentLocation {
            HOURLYFORECAST_URL = String(format: "https://api.weatherbit.io/v2.0/forecast/hourly?city=%@,%@&hours=24&key=cff8edafa3ea41059a4e21a29483afe7", location.city, location.countryCode)
        } else {
            HOURLYFORECAST_URL = CURRENTLOCATIONHOURLYFORECAST_URL
        }
        
        
        AF.request(HOURLYFORECAST_URL).responseJSON { (response) in
            
            var forecastArray: [HourlyForecast] = []
            
            switch response.result {
            case.success(_):
                 let json = JSON(response.data!)
                if let dictionary = response.value as? Dictionary<String, AnyObject> {
                    if let list = dictionary["data"] as? [Dictionary<String, AnyObject>] {
                        for item in list {
                            let forecast = HourlyForecast(weatherDictionary: item)
                            forecastArray.append(forecast)
                        }
                    }
                }
                completion(forecastArray)
            case.failure(let error):
            print(error.localizedDescription)
            
            }
        }
    }
    
}
