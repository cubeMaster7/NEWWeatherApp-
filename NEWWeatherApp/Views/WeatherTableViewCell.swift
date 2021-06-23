//
//  WeatherTableViewCell.swift
//  NEWWeatherApp
//
//  Created by Paul James on 14.06.2021.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {
    @IBOutlet weak var dayOfTheWeek: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var weatherIconImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

    func generateCell(forecast: WeeklyForecast) {
        
        dayOfTheWeek.text = forecast.date.dayOfTheWeek()
        weatherIconImage.image = getWeatherIconFor(forecast.weatherIcon)
        tempLabel.text = String(format: "%.0f%@", forecast.temp, returnTempFormatFromUserDefaults())

        
    }
    
}
