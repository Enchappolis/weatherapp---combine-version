//
//  CityListTableViewCell.swift
//  weatherapp
//
//  Created by Enchappolis on 7/28/20.
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

protocol CityListTableViewCellDelegate: AnyObject {
    
    func showAlert(title: String, messag: String)
}

class CityListTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var cityTemperature: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    
    // MARK: - Private Variables
    private var state = ""
    private var country = ""
    
    private var subscribers = Set<AnyCancellable>()
    private var cityWeatherViewModel = CityWeatherViewModel()
    private var cityCurrentWeatherViewModel: CityCurrentWeatherViewModel! {
        didSet {
            assignWeatherToLabels()
        }
    }
    
    // MARK: - Public Variables
    static let tableViewCellName = "CityListTableViewCell"
    weak var delegate: CityListTableViewCellDelegate?
    
    // MARK: - Private Methods
    private func hideLabels() {
        
        cityLabel.isHidden = true
        cityTemperature.isHidden = true
        self.weatherIconImageView.image = nil
    }
    
    private func showLabels() {
        
        cityLabel.isHidden = false
        cityTemperature.isHidden = false
    }
    
    // MARK: - Public Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        subscribers.removeAll()
    }
    
    private func assignWeatherToLabels() {
        
        self.cityLabel.text = "N/A"
        self.cityTemperature.text = ""

        let nameStateCountry = cityCurrentWeatherViewModel.nameStateCountry(forState: self.state, andCountry: self.country, withfontSize: 20)

        self.cityLabel.attributedText = nameStateCountry
        
        self.cityTemperature.text = cityCurrentWeatherViewModel.temperature
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
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
            
            self.cityCurrentWeatherViewModel = cityCurrentWeatherViewModel
            
            let weatherIconID = cityCurrentWeatherViewModel.icon
            
            self.cityWeatherViewModel.fetchCurrentWeatherIcon(forIconID: weatherIconID)
        }
        
        let stateCityCurrentWeatherViewModel: (CityWeatherViewModel.CityWeatherViewModelState) -> Void = { [weak self] cityWeatherViewModelState in
            
            guard let self = self else { return }
            
            switch cityWeatherViewModelState {
            case .loading:
                GlobalActivityIndicator.showActivityIndicator(inTableViewCell: self)
                self.hideLabels()
            case .finishedLoading:
                GlobalActivityIndicator.hideActivityIndicator(inTableViewCell: self)
                self.showLabels()
            case .error(let sessionError):
                self.subscribers.removeAll()
                GlobalActivityIndicator.hideActivityIndicator(inTableViewCell: self)
                self.cityLabel.text = "N/A"
                self.cityTemperature.text = ""
                self.weatherIconImageView.image = nil
                self.delegate?.showAlert(title: "Error", messag: sessionError.errorMessage)
            default:
                break
            }
        }
        
        self.cityWeatherViewModel.$cityCurrentWeatherViewModel
            .sink(receiveValue: receiveValueCityCurrentWeatherViewModel)
            .store(in: &subscribers)
        
        self.cityWeatherViewModel.$state
            .sink(receiveValue: stateCityCurrentWeatherViewModel)
            .store(in: &subscribers)
    }
    
    func configure(cityWeather: CDCityWeather, delegateForAlert: CityListTableViewCellDelegate) {
        
        delegate = delegateForAlert
        
        let id = String(cityWeather.id)
        self.state = cityWeather.state ?? ""
        self.country = cityWeather.country ?? ""
        
        GlobalActivityIndicator.showActivityIndicator(inTableViewCell: self)
        hideLabels()
        
        subscribeToCityWeatherViewModel()
        
        self.cityWeatherViewModel.fetchCurrentWeather(forCityID: id)
    }
}
