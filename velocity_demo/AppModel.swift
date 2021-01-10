//
//  AppModel.swift
//  velocity_demo
//
//  Created by Jerry Walton on 1/8/21.
//

import Foundation

class AppModel {
    
    static let sharedInstance = AppModel()
    
    public var searchKeys = [String]()
    public var weatherResults = [WeatherResult]()
    
    public func addSearchKey(searchKey: String) {
        searchKeys.append(searchKey)
    }
    public func clearSearchKeys() {
        searchKeys.removeAll()
    }
    public func addWeatherResult(weatherResult: WeatherResult) {
        weatherResults.append(weatherResult)
    }
    public func clearWeatherResults() {
        weatherResults.removeAll()
    }
}
