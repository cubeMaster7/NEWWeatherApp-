//
//  GlobalHelper.swift
//  NEWWeatherApp
//
//  Created by Paul James on 12.06.2021.
//

import Foundation
import UIKit

func currentDateFromUnix(unixDate: Double?) -> Date? {
    if unixDate != nil {
        return Date(timeIntervalSince1970: unixDate!)
    } else{
        return Date()
    }
    
   
}
func getWeatherIconFor(_ type: String) -> UIImage? {
    return UIImage(named: type)
}


func fahrenheitFrom(celsius: Double) -> Double {
    return(celsius * 9/5)+32
}

func getTempBasedOnSetting(celsius: Double) -> Double {
    
    let format = returnTempFormatFromUserDefaults()
    
    if format == TempFormat.celsius {
        return celsius
    } else {
        return fahrenheitFrom(celsius: celsius)
    }
}

func returnTempFormatFromUserDefaults() -> String {
    if let tempFormat = UserDefaults.standard.value(forKey: "tempFormat") {
        if tempFormat as! Int == 0 {
            return TempFormat.celsius
        } else {
            return TempFormat.fahrenheit
        }
    } else {
        return TempFormat.celsius
    }
}
