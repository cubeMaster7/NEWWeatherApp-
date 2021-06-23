//
//  AllLocationsTableViewController.swift
//  NEWWeatherApp
//
//  Created by Paul James on 18.06.2021.
//

import UIKit

protocol AllLocationsTableViewControllerDelegate {
    func didChooseLocation(atIndex: Int, shouldRefresh: Bool)
}

class AllLocationsTableViewController: UITableViewController {
    
    //MARK: Outlets
    @IBOutlet weak var tempSegmentOutlet: UISegmentedControl!
    @IBOutlet weak var footerView: UIView!
    
    
    var savedLoactions:[WeatherLocation]?
    let userDefaults = UserDefaults.standard
    var weatherData: [CityTempData]?
    var delegate: AllLocationsTableViewControllerDelegate?
    
    var shouldRefresh = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = footerView
        loadLocationsFromUserDefaults()
        loadTempFormatFromUserDefaults()
       
    }
    
    //MARK: IBAction
    @IBAction func tempSegmentValueChanged(_ sender: UISegmentedControl) {
        
        updateTempFormatInsUserDefaults(newValue: sender.selectedSegmentIndex)
    }
    
    private func updateTempFormatInsUserDefaults(newValue: Int) {
        shouldRefresh = true
        userDefaults.setValue(newValue, forKey: "tempFormat")
        userDefaults.synchronize()
    }
    
    private func loadTempFormatFromUserDefaults() {
        if let index = userDefaults.value(forKey: "tempFormat") {
            tempSegmentOutlet.selectedSegmentIndex = index as! Int
        } else {
            tempSegmentOutlet.selectedSegmentIndex = 0
        }
    }
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return weatherData?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MainWeatherTableViewCell

        if weatherData != nil {
            cell.generateCell(weatherData: weatherData![indexPath.row])
        }
        
        return cell
    }
    
    //MARK: TableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        delegate?.didChooseLocation(atIndex: indexPath.row, shouldRefresh: shouldRefresh)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != 0
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let locationDelete = weatherData?[indexPath.row]
            weatherData?.remove(at: indexPath.row)
            
            
            removeLocationFromSavedLocation(location: locationDelete!.city)
            tableView.reloadData()
        }
    }
    
    private func removeLocationFromSavedLocation(location: String) {
        
        if savedLoactions != nil {
            for i in 0 ..< savedLoactions!.count {
                let tempLocation = savedLoactions![i]
                if tempLocation.city == location {
                    savedLoactions?.remove(at: i)
                    saveNewLocatonsToUserDefaults()
                    return
                }
            }
        }
    }
    
    private func saveNewLocatonsToUserDefaults() {
        
        shouldRefresh = true
        userDefaults.setValue(try? PropertyListEncoder().encode(savedLoactions), forKey: "Locations")
        userDefaults.synchronize()
    }
    
    
    //MARK: UserDefaults
    
    private func loadLocationsFromUserDefaults() {
        if let data = userDefaults.value(forKey: "Locations") as? Data{
            savedLoactions = try? PropertyListDecoder().decode(Array<WeatherLocation>.self, from: data)
//            print("We have \(savedLoactions?.count) locations in UD")
        }
    }
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chooseLocationSegue" {
            let vc = segue.destination as! ChooseCityViewController
            vc.delegate = self
        }
    }
 
}


extension AllLocationsTableViewController: ChooseCityViewControllerDelegate {
    func didAdd(newLocation: WeatherLocation) {
        shouldRefresh = true
        weatherData?.append(CityTempData(city: newLocation.city, temp: 0.0))
        tableView.reloadData()
    }
    
    
}
