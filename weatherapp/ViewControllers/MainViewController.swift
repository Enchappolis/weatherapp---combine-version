//
//  MainViewController.swift
//  weatherapp
//
//  Created by Enchappolis on 7/26/20.
//  Copyright © 2020 Enchappolis. All rights reserved.
//  https://github.com/Enchappolis
/*
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 distribute, sublicense, create a derivative work, and/or sell copies of the
 Software in any work that is designed, intended, or marketed for pedagogical or
 instructional purposes related to programming, coding, application development,
 or information technology.  Permission for such use, copying, modification,
 merger, publication, distribution, sublicensing, creation of derivative works,
 or sale is expressly withheld.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
*/

import UIKit
import Combine

class MainViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var tableView5Days3Hours: UITableView!
    
    // MARK: - Private Variables
    private struct StoryBoards {
        
        static let cityListViewController = "CityListViewController"
        static let settingsViewController = "SettingsViewController"
    }
    
    // Hide all views on app start.
    private var hideView: UIView!
    
    private var subscribers = Set<AnyCancellable>()
    
    private var cityId = ""
    private var weatherIconID = ""
    
    // Need state and country because it is not returned by api for current weather.
    private var state = ""
    private var country = ""
    
    private lazy var cityWeatherCoreDataHandler: CDCityWeatherCoreDataHandler = {
        
        let cityWeatherCoreDataHandler = CDCityWeatherCoreDataHandler()
        return cityWeatherCoreDataHandler
    }()
    
    private var cityWeatherViewModel = CityWeatherViewModel()
    private var city5Days3HoursListViewModel: City5Days3HoursListViewModel!
    
    // MARK: - Actions
    @IBAction func settingaBarButtonItemTapped(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: StoryBoards.settingsViewController, sender: nil)
    }
    
    @IBAction func citySearchBarButtonItemTapped(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: StoryBoards.cityListViewController, sender: nil)
    }
    
    // MARK: - Private Methods
    private func subscribeToCityWeatherViewModel() {
        
        // Weather Icon.
        let receiveValueWeatherIcon: (UIImage) -> Void = { [weak self] weatherIcon in

            guard let self = self else { return }

            self.weatherIconImageView.image = weatherIcon
        }

        self.cityWeatherViewModel.$weatherIcon
            .sink(receiveValue: receiveValueWeatherIcon)
            .store(in: &subscribers)
        
        // Current Weather.
        let receiveValueCityCurrentWeatherViewModel: (CityCurrentWeatherViewModel?) -> Void = { [weak self] cityCurrentWeatherViewModel in
            
            guard let self = self else { return }
            
            guard let cityCurrentWeatherViewModel = cityCurrentWeatherViewModel else { return }
            
            let nameStateCountry = cityCurrentWeatherViewModel.nameStateCountry(
                forState: self.state, andCountry: self.country, withfontSize: 45)
            
            self.cityLabel.attributedText = nameStateCountry
            self.weatherDescriptionLabel.text = cityCurrentWeatherViewModel.weatherDescription
            self.temperatureLabel.text = cityCurrentWeatherViewModel.temperature
            
            self.weatherIconID = cityCurrentWeatherViewModel.icon
            
            Hud.hide(from: self.view)
            self.showAllViews()
        }
        
        let receiveValueCityWeatherViewModelState: (CityWeatherViewModel.CityWeatherViewModelState) -> Void = { [weak self] cityWeatherViewModelState in
            
            guard let self = self else { return }
            
            switch cityWeatherViewModelState {
            case .finishedLoading(let stateType):
                switch stateType {
                case .currentWeather:
                    self.cityWeatherViewModel.fetchCurrentWeatherIcon(forIconID: self.weatherIconID)
                case .weatherIcon:
                    TableViewActivityIndicator.showLoadingScreen(tableView: self.tableView5Days3Hours)
                    self.cityWeatherViewModel.fetch5Days3HoursWeather(forCityID: self.cityId)
                default:
                    break
                }
            case .error(let sessionError):
                Hud.hide(from: self.view)
                self.showAlertOK(title: "Error", message: sessionError.errorMessage)
            default:
                break
            }
        }
        
        self.cityWeatherViewModel.$cityCurrentWeatherViewModel
            .sink(receiveValue: receiveValueCityCurrentWeatherViewModel)
            .store(in: &subscribers)
        
        self.cityWeatherViewModel.$state
            .sink(receiveValue: receiveValueCityWeatherViewModelState)
            .store(in: &subscribers)
        
        // 5Days3Hours
        let city5Days3HoursListCompletionHandler: (City5Days3HoursListViewModel?) -> Void = { [weak self] city5Days3HoursListViewModel in

            guard let self = self else { return }

            guard let city5Days3HoursListViewModel = city5Days3HoursListViewModel else { return }

            TableViewActivityIndicator.removeLoadingScreen()
            
            self.city5Days3HoursListViewModel = city5Days3HoursListViewModel

            self.tableView5Days3Hours.reloadData()
        }
        
        self.cityWeatherViewModel.$city5Days3HoursListViewModel
        .sink(receiveValue: city5Days3HoursListCompletionHandler)
        .store(in: &subscribers)
    }
    
    private func getWeatherData() {
        
        cityWeatherCoreDataHandler.fetchSelectedCityWeater { [weak self] (cdCityWeather) in
            
            guard let self = self else { return }
            
            guard let cdCityWeather = cdCityWeather else {
                return
            }
            
            self.cityId = String(cdCityWeather.id)
            self.state = cdCityWeather.state ?? ""
            self.country = cdCityWeather.country ?? ""
            
            self.cityWeatherViewModel.fetchCurrentWeather(forCityID: self.cityId)
        }
    }
    
    private func hideAllViews() {
       
        hideView = UIView(frame: CGRect(x: 0,
                                        y: 0,
                                        width: self.view.bounds.width,
                                        height: self.view.bounds.height))
        hideView.tag = 201
        hideView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
 
        self.view.addSubview(hideView)
    }
    
    private func showAllViews() {
        
        if let view = self.view.viewWithTag(201) {
            view.removeFromSuperview()
            hideView.removeFromSuperview()
        }
    }
    
    // MARK: - View Load
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView5Days3Hours.dataSource = self
        tableView5Days3Hours.delegate = self
        tableView5Days3Hours.rowHeight = 80
        
        subscribeToCityWeatherViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showAllViews()
        hideAllViews()
        Hud.show(onTopOf: self.view)
        
        self.getWeatherData()
    }
}

// MARK: - UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.city5Days3HoursListViewModel != nil ? self.city5Days3HoursListViewModel.numberOfSections : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.city5Days3HoursListViewModel != nil ? self.city5Days3HoursListViewModel.numberOfRowsInSection : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cityWeather5Days3HoursTableViewCell = tableView.dequeueReusableCell(withIdentifier: CityWeather5Days3HoursTableViewCell.tableViewCellName) as? CityWeather5Days3HoursTableViewCell {
            
            cityWeather5Days3HoursTableViewCell.city5Days3HoursAllHoursForOneDayViewModelList = self.city5Days3HoursListViewModel.cellForRowAtIndexPath(indexPath: indexPath)
            
            return cityWeather5Days3HoursTableViewCell
        }
        
        return UITableViewCell()
    }
}

// MARK: - UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return self.city5Days3HoursListViewModel != nil
            ? self.city5Days3HoursListViewModel.titleForHeaderInSection(section: section)
            : ""
    }
}
