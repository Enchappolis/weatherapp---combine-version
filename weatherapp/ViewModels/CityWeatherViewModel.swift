//
//  CityWeatherViewModel.swift
//  weatherapp
//
//  Created by Enchappolis on 9/10/20.
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

class CityWeatherViewModel {
    
    @Published private(set) var cityCurrentWeatherViewModel: CityCurrentWeatherViewModel!
    @Published private(set) var city5Days3HoursListViewModel: City5Days3HoursListViewModel!
    @Published private(set) var weatherIcon = UIImage()
    @Published private(set) var state = CityWeatherViewModelState.undefined
    
    enum StateType {
        case currentWeather
        case weatherIcon
        case _5Days3Hours
    }
    
    enum CityWeatherViewModelState {
        case undefined
        case loading
        case finishedLoading(StateType)
        case error(WANetworkError.NetworkError)
    }
    
    private var subscriber: AnyCancellable?

    func fetchCurrentWeather(forCityID: String) {
        
        guard !forCityID.isEmpty else {
            return
        }
        
        guard let url = WAClient.Endpoints.currentWeather(forCityID).url else {
            return
        }
        
        self.state = .loading
        
        subscriber = WAClient.requestWeather(for: url, responseType: WACityCurrentWeather.self)
            .sink(receiveCompletion: { (completion) in
                
                switch completion {
                case .finished:
                    self.state = .finishedLoading(.currentWeather)
                case .failure(let networkError):
                    self.state = .error(networkError)
                }
            }, receiveValue: { waCityCurrentWeather in
                
                self.cityCurrentWeatherViewModel = CityCurrentWeatherViewModel(waCityCurrentWeather: waCityCurrentWeather)
            })
    }
    
    func fetch5Days3HoursWeather(forCityID: String) {
        
        guard !forCityID.isEmpty else {
            return
        }
        
        guard let url = WAClient.Endpoints._5Days3Hours(forCityID).url else {
            return
        }
        
        self.state = .loading
        
        subscriber = WAClient.requestWeather(for: url, responseType: WACity5Days3Hours.self)
            .sink(receiveCompletion: { (completion) in
                
                switch completion {
                case .finished:
                    self.state = .finishedLoading(._5Days3Hours)
                case .failure(let networkError):
                    self.state = .error(networkError)
                }
            }, receiveValue: { waCityCurrentWeather in
                
                self.city5Days3HoursListViewModel = City5Days3HoursListViewModel(waCity5Days3Hours: waCityCurrentWeather)
            })
    }
    
    func fetchCurrentWeatherIcon(forIconID: String) {
        
        guard !forIconID.isEmpty else {
            return
        }
        
        guard let url = WAClient.Endpoints.icon(forIconID).url else {
            return
        }
        
        self.state = .loading
        
        subscriber = WAClient.requestCurrentWeatherIcon(for: url)
            .sink(receiveCompletion: { (completion) in
                
                switch completion {
                case .finished:
                    self.state = .finishedLoading(.weatherIcon)
                case .failure(let networkError):
                    self.state = .error(networkError)
                }
                
            }, receiveValue: { image in
                
                self.weatherIcon = image
            })
    }
}
