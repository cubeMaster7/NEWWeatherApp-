//
//  WeatherViewController.swift
//  NEWWeatherApp
//
//  Created by Paul James on 13.06.2021.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {

    @IBOutlet weak var weatherScrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var weatherLocation: WeatherLocation!
    
    var locationManager: CLLocationManager?
    var currentLocation: CLLocationCoordinate2D!
    
    let userDefaults = UserDefaults.standard
    var allLocations: [WeatherLocation] = []
    var allWeatherViews: [WeatherView] = []
    var allWeatherData: [CityTempData] = []
    
    var shouldRefresh = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManagerStart()
        weatherScrollView.delegate = self

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if shouldRefresh {
            allLocations = []
            allWeatherViews = []
            removeViewsFromScrollView()
            locationAuthCheck()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManagerStop()
    }
  
    //MARK: Download Weather
    
    private func getWeather() {
        
        loadLocationsFormFromUserDefaults()
        createWeatherViews()
        addWeatherToScrollView()
        setPageControllPageNumber()
    }
    
    private func removeViewsFromScrollView() {
        for view in weatherScrollView.subviews {
            view.removeFromSuperview()
        }
    }
    
    private func createWeatherViews() {
        for _ in allLocations {
            allWeatherViews.append(WeatherView())
        }
    }
    
    private func addWeatherToScrollView() {
        for i in 0 ..< allWeatherViews.count {
            let weatherView = allWeatherViews[i]
            let location = allLocations[i]
            
            
            getCurrentWeather(weatherView: weatherView, location: location)
            getWeeklyWeather(weatherView: weatherView, location: location)
            getHourlyWeather(weatherView: weatherView, location: location)
            
            //тут мы указываем логику горизонтального скролла скроллВью
            let xPos = self.view.frame.width * CGFloat(i)
            weatherView.frame = CGRect(x: xPos, y: 0, width: weatherScrollView.bounds.width, height: weatherScrollView.bounds.height)
            
            weatherScrollView.addSubview(weatherView)
            //как сильно надо скролить
            weatherScrollView.contentSize.width = weatherView.frame.width * CGFloat(i+1)
        }
    }
    
    private func getCurrentWeather(weatherView: WeatherView, location: WeatherLocation){
        weatherView.currentWeather = CurrentWeather()
        weatherView.currentWeather.getCurrentWeather(location: location) { (success) in
            weatherView.refreshData()
            
            self.generateWeatherList()
        }
    }
    
    private func getWeeklyWeather(weatherView: WeatherView, location: WeatherLocation){
        WeeklyForecast.downloadWeeklyWeatherForecast(location: location) { (weatherForecasts) in
            weatherView.weeklyWeatherForecastData = weatherForecasts
            weatherView.tableView.reloadData()
        }
    }
    
    private func getHourlyWeather(weatherView: WeatherView, location: WeatherLocation){
        HourlyForecast.downloadDailyForecastWeather(location: location) { (weatherForecasts) in
            weatherView.dailyWeatherForecastData = weatherForecasts
            weatherView.hourlyCollectionView.reloadData()
        }
    }
    
    //MARK: loadLocations form userDeafualts
    
    private func loadLocationsFormFromUserDefaults() {
        
        let currentLocation = WeatherLocation(city: "", country: "", countryCode: "" , isCurrentLocation: true)
        
        if let data = userDefaults.value(forKey: "Locations") as? Data {
            
            allLocations = try! PropertyListDecoder().decode(Array<WeatherLocation>.self, from: data)
            
            allLocations.insert(currentLocation, at: 0)
        
        } else {
            print("no user data in user defaults")
            allLocations.append(currentLocation)
        }
        
    }
    
    
    //MARK: Page Controll
    
    private func setPageControllPageNumber(){
        //как много страниц должен содержать пейдж контрол - столько сколько элементов сохранено в массиве
        pageControl.numberOfPages = allWeatherViews.count
        
    }
    
    private func updatePageControlSelectedPage(currentPage: Int) {
        pageControl.currentPage = currentPage
    }
    
    
    
    //MARK: LocationManager
    
    private func locationManagerStart() {
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.requestWhenInUseAuthorization()
            locationManager!.delegate = self
        }
        locationManager?.startMonitoringSignificantLocationChanges()
    }
    
    private func locationManagerStop() {
        if locationManager != nil {
            locationManager!.stopMonitoringSignificantLocationChanges()
        }
    }
    
    private func locationAuthCheck() {
        
        let manager = CLLocationManager()
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            currentLocation = manager.location?.coordinate
            if currentLocation != nil {
                
                // set our coordinate
                
                LocationService.shared.latitude = currentLocation.latitude
                LocationService.shared.longitude = currentLocation.longitude
                
                getWeather()
            } else {
                print("SMTH went wrong with locationAuthCheck")
                locationAuthCheck()
            }
            
        default:
            manager.requestWhenInUseAuthorization()
            locationAuthCheck()
        }
    }
    
    private func generateWeatherList() {
        allWeatherData = []
        for weatherView in allWeatherViews {
            allWeatherData.append(CityTempData(city: weatherView.currentWeather.city, temp: weatherView.currentWeather.currentTemp))
        }
    }
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "allLocationSeg" {
            let vc = segue.destination as! AllLocationsTableViewController
            vc.weatherData = allWeatherData
            vc.delegate = self
        }
    }

}

extension WeatherViewController: AllLocationsTableViewControllerDelegate {
    func didChooseLocation(atIndex: Int, shouldRefresh: Bool) {
        //тут нам надо понять под каким индексом у нас выбранное вью
        
        let viewNumber = CGFloat(integerLiteral: atIndex)
        let newOffset = CGPoint(x: (weatherScrollView.frame.width + 1.0) * viewNumber, y: 0)
        weatherScrollView.setContentOffset(newOffset, animated: true)
        
        updatePageControlSelectedPage(currentPage: atIndex)
        
        self.shouldRefresh = shouldRefresh
    }
    
    
}

extension WeatherViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Faild to get location, \(error.localizedDescription)")
    }
    
}

extension WeatherViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //проверяем где мы скролим
        
        let value = scrollView.contentOffset.x / scrollView.frame.size.width
        updatePageControlSelectedPage(currentPage: Int(round(value)))
    }
}
