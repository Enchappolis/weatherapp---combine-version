//
//  WAClient.swift
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

class WAClient {
    
    enum Endpoints {
        
        static let base = "https://api.openweathermap.org/data/2.5/"
        static let apiKeyParam = "\(WAAPIKey.key.rawValue)"
        static let iconBase = "https://openweathermap.org/img/wn/" // 10d@2x.png"
        
        // Current weather.
        // api.openweathermap.org/data/2.5/weather?id={city id}&appid={your api key}
        
        // 5Days3Hours
        // api.openweathermap.org/data/2.5/forecast?id={city ID}&appid={your api key}
        
        case currentWeather(String)
        case _5Days3Hours(String)
        case icon(String)
        
        private var stringValue: String {
            
            switch self {
            case .currentWeather(let cityID):
                return "\(Endpoints.base)weather?id=\(cityID)&appid=\(Endpoints.apiKeyParam)"
            case ._5Days3Hours(let cityID):
                return "\(Endpoints.base)forecast?id=\(cityID)&appid=\(Endpoints.apiKeyParam)"
            case .icon(let iconID):
                return "\(Endpoints.iconBase)\(iconID)@2x.png"
            }
        }
        
        var url: URL? {
            return URL(string: stringValue)
        }
    }
    
    static func requestWeather<ResponseType: Decodable>(for url: URL,
                                                        responseType: ResponseType.Type) -> AnyPublisher<ResponseType, WANetworkError.NetworkError> {
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .tryMap({ (data, response) -> Data in
                
                if let response = response as? HTTPURLResponse,
                    (200..<300).contains(response.statusCode) == false {
                    throw WANetworkError.NetworkError.statusCode(response)
                }
                
                return data
            })
            .decode(type: ResponseType.self, decoder: JSONDecoder())
            .mapError({ error in
                
                switch error {
                case is URLError:
                    return WANetworkError.NetworkError.urlError
                case is DecodingError:
                    return WANetworkError.NetworkError.decodingError("Error decoding object")
                case is WANetworkError.NetworkError:
                    return error as! WANetworkError.NetworkError
                default:
                    return WANetworkError.NetworkError.error(error.localizedDescription)
                }
            })
            .eraseToAnyPublisher()
    }
    
    static func requestCurrentWeatherIcon(for url: URL) -> AnyPublisher<UIImage, WANetworkError.NetworkError> {
        
        return  URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .tryMap({ (data, response) -> Data in
                
                if let response = response as? HTTPURLResponse,
                    (200..<300).contains(response.statusCode) == false {
                    throw WANetworkError.NetworkError.statusCode(response)
                }
                
                return data
            })
            .compactMap { UIImage(data: $0) }
            .mapError({ error in
                
                switch error {
                case is WANetworkError.NetworkError:
                    return error as! WANetworkError.NetworkError
                default:
                    return WANetworkError.NetworkError.error(error.localizedDescription)
                }
            })
            .eraseToAnyPublisher()
    }
}
