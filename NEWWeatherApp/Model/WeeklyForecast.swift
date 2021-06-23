//
//  WeaklyForecast.swift
//  NEWWeatherApp
//
//  Created by Paul James on 12.06.2021.
//

import Foundation
import Alamofire
import SwiftyJSON

class WeeklyForecast {
    
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
    
    
    class func downloadWeeklyWeatherForecast(location: WeatherLocation, completion: @escaping (_ weatherForecast:[WeeklyForecast]) -> Void) {
//        let WEEKLYFORECAST_URL = "https://api.weatherbit.io/v2.0/forecast/daily?lat=59.9386300&lon=30.3141300&days=7&key=cff8edafa3ea41059a4e21a29483afe7"
        
        
        var WEEKLYFORECAST_URL: String!
        
        if !location.isCurrentLocation {
            WEEKLYFORECAST_URL = String(format: "https://api.weatherbit.io/v2.0/forecast/daily?city=%@,%@&days=7&key=cff8edafa3ea41059a4e21a29483afe7", location.city, location.countryCode)
        } else {
            WEEKLYFORECAST_URL = CURRENTLOCATIONWEEKLYFORECAST_URL
        }
        
        AF.request(WEEKLYFORECAST_URL).responseJSON { (response) in
            var forecastArray: [WeeklyForecast] = []
            
            switch response.result {
            
            case.success(var json):
                json = JSON(response.data!)
                
                if let dictionary = response.value as? Dictionary<String, AnyObject>{
                    if var list = dictionary["data"] as? [Dictionary<String, AnyObject>] {
                        list.remove(at: 0) //remove current day

                        
                        for item in list {
                            let forecast = WeeklyForecast(weatherDictionary: item)
                            forecastArray.append(forecast)
                        }
                    }
                }
                
                
                completion(forecastArray)
            case.failure(let error):
                completion(forecastArray)
                print(error.localizedDescription)
            
            
            
            }
        }
        
        
    }
    
    
}
