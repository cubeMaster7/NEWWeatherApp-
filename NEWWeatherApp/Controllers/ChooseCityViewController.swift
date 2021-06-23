//
//  ChooseCityViewController.swift
//  NEWWeatherApp
//
//  Created by Paul James on 18.06.2021.
//

import UIKit

protocol ChooseCityViewControllerDelegate {
    func didAdd(newLocation: WeatherLocation)
}

class ChooseCityViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Variables
    var allLocations:[WeatherLocation] = []
    var filteredLocations: [WeatherLocation] = []
    
    //создаем серчКонтроллер
    
    let searchController = UISearchController(searchResultsController: nil)
    let userDefaults = UserDefaults.standard
    var savedLocations: [WeatherLocation]?
    var delegate: ChooseCityViewControllerDelegate?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        loadFromUserDefaults()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        setupSearchController()
        tableView.tableHeaderView = searchController.searchBar
        setupTapGesture()
        loadLocationsFromCVS()

      
    }
    
    private func setupSearchController() {
        
        searchController.searchBar.placeholder = "Citi of Country"
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        searchController.searchBar.searchBarStyle = UISearchBar.Style.prominent
        searchController.searchBar.sizeToFit()
        searchController.searchBar.backgroundImage = UIImage()
        
    }
    
    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tableTapped))
        self.tableView.backgroundView = UIView()
        self.tableView.backgroundView?.addGestureRecognizer(tap)
        
    }
    
    @objc func tableTapped() {
        dismissView()
    }
    
    private func dismissView() {
        if searchController.isActive {
            searchController.dismiss(animated: true) {
                self.dismiss(animated: true)
            }
        } else {
            self.dismiss(animated: true)
        }
    }
    
    //MARK: Get Locations
    
    private func loadLocationsFromCVS() {
        if let path = Bundle.main.path(forResource: "cities_20000", ofType: "csv") {
            parseCSVAt(url: URL(fileURLWithPath: path))
        }
    }
    
    private func parseCSVAt(url: URL) {
        
        do{
            
            let data = try Data(contentsOf: url)
            let dataEncoded = String(data: data, encoding: .utf8)
            
            if let dataArr = dataEncoded?.components(separatedBy: "\n").map({$0.components(separatedBy: ",")}) {
                
                var i = 0
                for line in dataArr {
                    if line.count > 2 && i != 0 {
                        createLocation(line: line)
                    }
                    i += 1
                }
            }
            
        } catch{
            print("Error reading CSV file", error.localizedDescription)
        }
        
    }
    
    private func createLocation(line: [String]) {
        
        allLocations.append(WeatherLocation(city: line[1], country: line[4], countryCode: line[3], isCurrentLocation: false))
//        print(allLocations.count)
        
    }
    
    //MARK: user defaults
    
    private func saveToUserDefaults(location: WeatherLocation) {
        
        if savedLocations != nil {
            if !savedLocations!.contains(location) {
                savedLocations!.append(location)
            }
            
        } else {
            savedLocations = [location]
        }
        
        userDefaults.set(try? PropertyListEncoder().encode(savedLocations!), forKey: "Locations")
        userDefaults.synchronize()
    }
    
    private func loadFromUserDefaults(){
        if let data = userDefaults.value(forKey: "Locations") as? Data {
            
            savedLocations = try? PropertyListDecoder().decode(Array<WeatherLocation>.self, from: data)
//            print(savedLocations?.last?.country)
        }
    }

}

extension ChooseCityViewController: UISearchResultsUpdating {
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {

        filteredLocations = allLocations.filter({ (location) -> Bool in
            return location.city.lowercased().contains(searchText.lowercased()) || location.country.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()

    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}


extension ChooseCityViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let location = filteredLocations[indexPath.row]
        cell.textLabel?.text = location.city
        cell.detailTextLabel?.text = location.country
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //save locations
        
        tableView.deselectRow(at: indexPath, animated: true)
        saveToUserDefaults(location: filteredLocations[indexPath.row])
        delegate?.didAdd(newLocation: filteredLocations[indexPath.row])
        dismissView()
        
    }
    
}
