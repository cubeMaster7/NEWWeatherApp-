//
//  InfoCollectionViewCell.swift
//  NEWWeatherApp
//
//  Created by Paul James on 14.06.2021.
//

import UIKit

class InfoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    
    func generateCell(weatherInfo: WeatherInfo) {
        infoLabel.text = weatherInfo.infoText
        infoLabel.adjustsFontSizeToFitWidth = true
        
        if weatherInfo.image != nil {
            nameLabel.isHidden = true
            infoImageView.isHidden = false
            infoImageView.image = weatherInfo.image
        }else {
            //no image
            nameLabel.isHidden = false
            infoImageView.isHidden = true
            nameLabel.adjustsFontSizeToFitWidth = true
            nameLabel.text = weatherInfo.nameText
            
        }
    }
    
}
