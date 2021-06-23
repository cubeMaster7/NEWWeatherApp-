//
//  MainWeatherTableViewCell.swift
//  NEWWeatherApp
//
//  Created by Paul James on 20.06.2021.
//

import UIKit

class MainWeatherTableViewCell: UITableViewCell {

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    func generateCell(weatherData: CityTempData) {
        cityLabel.text = weatherData.city
        cityLabel.adjustsFontSizeToFitWidth = true
        tempLabel.text = String(format:"%.0f %@", weatherData.temp,returnTempFormatFromUserDefaults())
    }

}
