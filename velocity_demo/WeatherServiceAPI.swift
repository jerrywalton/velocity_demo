//
//  WeatherServiceAPI.swift
//  velocity_demo
//
//  Created by Jerry Walton on 1/5/21.
//

import Foundation

public let weatherAPIKey = "fb8ca5789d91c4a2fdd8bcd032fe83ac"
public let baseWeatherAPIURLString = "http://api.openweathermap.org/data/2.5/weather"
//api.openweathermap.org/data/2.5/weather?zip={zip code},{country code}&appid={API key}

extension Notification.Name {
    static let SearchKeysUpdatedNotif = Notification.Name(rawValue: "SearchKeysUpdatedNotif")
    static let WeatherResultsUpdatedNotif = Notification.Name(rawValue: "WeatherResultsUpdatedNotif")
}

//enum CoordCodingKeys: CodingKey {
//  case lon, lat
//}
public struct Coord: Codable {
    public let lon: Double?
    public let lat: Double?
}

//enum WeatherCodingKeys: CodingKey {
//    case id, main, description, icon
//}
public struct Weather: Codable {
    public let id: Int?
    public let main: String?
    public let description: String?
    public let icon: String?
}

//enum MainCodingKeys: CodingKey {
//  case temp, feels_like, temp_min, temp_max, pressure, humidity
//}
public struct Main: Codable {
    public let temp: Float?
    public let feels_like: Float?
    public let temp_min: Float
    public let temp_max: Float?
    public let pressure: Int?
    public let humidity: Int?
}

//enum WindCodingKeys: CodingKey {
//  case speed, deg
//}
public struct Wind: Codable {
    public let speed: Float?
    public let deg: Int?
}

//enum CloudsCodingKeys: CodingKey {
//  case all
//}
public struct Clouds: Codable {
    public let all: Int?
}

//enum SysCodingKeys: CodingKey {
//  case type, id, country, sunrise, sunset
//}
public struct Sys: Codable {
    public let type: Int?
    public let id: Int?
    public let country: String?
    public let sunrise: Double?
    public let sunset: Double?
}

//enum WeatherResultCodingKeys: CodingKey {
//  case coord, weather, base, main, visibility, wind, clouds, dt, sys, timezone, id, name, cod
//}
public struct WeatherResult: Codable {
//    {
//       "coord":{
//          "lon":-87.3653,
//          "lat":41.417
//       },
    public let coord: Coord?
//       "weather":[
//          {
//             "id":803,
//             "main":"Clouds",
//             "description":"broken clouds",
//             "icon":"04d"
//          }
//       ],
    public let weather: [Weather]?
//       "base":"stations",
    public let base: String?
//       "main":{
//          "temp":275.9,
//          "feels_like":272.81,
//          "temp_min":275.15,
//          "temp_max":276.48,
//          "pressure":1027,
//          "humidity":80
//       },
    public let main: Main?
//       "visibility":10000,
    public let visibility: Int?
//       "wind":{
//          "speed":1.5,
//          "deg":230
//       },
    public let wind: Wind?
//       "clouds":{
//          "all":75
//       },
    public let clouds: Clouds?
//       "dt":1609958692,
    public let dt: Double?
//       "sys":{
//          "type":1,
//          "id":4505,
//          "country":"US",
//          "sunrise":1609938935,
//          "sunset":1609972495
//       },
    public let sys: Sys?
//       "timezone":-21600,
    public let timezone: Int?
//       "id":4922493,
    public let id: Int32?
//       "name":"Chicago",
    public let name: String?
//       "cod":200
    public let cod: Int?
//    }
    
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: WeatherResultCodingKeys.self)
//        coord = try container.decode(Coord.self, forKey: WeatherResultCodingKeys.coord)
//        weather = try container.decode([Weather].self, forKey: WeatherResultCodingKeys.weather)
//        base = try container.decode(String.self, forKey: WeatherResultCodingKeys.base)
//        main = try container.decode(Main.self, forKey: WeatherResultCodingKeys.main)
//        visibility = try container.decode(Int.self, forKey: WeatherResultCodingKeys.visibility)
//        wind = try container.decode(Wind.self, forKey: WeatherResultCodingKeys.wind)
//        clouds = try container.decode(Clouds.self, forKey: WeatherResultCodingKeys.clouds)
//        dt = try container.decode(Double.self, forKey: WeatherResultCodingKeys.dt)
//        sys = try container.decode(Sys.self, forKey: WeatherResultCodingKeys.sys)
//        timezone = try container.decode(Int.self, forKey: WeatherResultCodingKeys.timezone)
//        id = try container.decode(Int32.self, forKey: WeatherResultCodingKeys.id)
//        name = try container.decode(String.self, forKey: WeatherResultCodingKeys.name)
//        cod = try container.decode(Int.self, forKey: WeatherResultCodingKeys.cod)
//    }
}

class WeatherServiceAPI {
    
    public enum APIServiceError: Error {
        case apiError
        case invalidEndpoint
        case invalidResponse
        case noData
        case decodeError
    }
    
    // singleton pattern
    public static let shared = WeatherServiceAPI()
    private init() {}
    
    private let urlSession = URLSession.shared
    private let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .useDefaultKeys
        jsonDecoder.dataDecodingStrategy = .deferredToData
        //        let dateFormatter = DateFormatter()
        //        //dateFormatter.dateFormat = "yyyy-mm-dd"
        //        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        //        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        return jsonDecoder
    }()
    
    // Enum Endpoint
    enum Endpoint: String {
        case zipCodeSearch   //Returns weather information for the given zip code in the search text.
    }
    
    func baseURLQueryString() -> String {
        return "\(baseWeatherAPIURLString)?appid=\(weatherAPIKey)"
    }
    
    public func fetchZipCodes(zipCodes: [String]) {
        AppModel.sharedInstance.clearWeatherResults()
        DispatchQueue.global().async {
            for zipCode in AppModel.sharedInstance.searchKeys {
                WeatherServiceAPI.shared.fetchZipCodeSearch(from: .zipCodeSearch, searchString: zipCode) { (result: Result<WeatherResult, WeatherServiceAPI.APIServiceError>) in
                    switch result {
                    case .success(let weatherResult):
                        //print("weatherResult: \(weatherResult)")
                        AppModel.sharedInstance.addWeatherResult(weatherResult: weatherResult)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
            NotificationCenter.default.post(name: .WeatherResultsUpdatedNotif, object: nil)
        }
    }
    
    public func fetchZipCodeSearch(from endpoint: Endpoint, searchString: String, result: @escaping (Result<WeatherResult, APIServiceError>) -> Void) {
        let fetchURL = URL(string: "\(baseURLQueryString())&q=\(searchString)")!
        print("fetchZipCodeSearch url: \(fetchURL)")
        fetchResources(url: fetchURL, completion: result)
    }
    
    private func fetchResources<T: Decodable>(url: URL, completion: @escaping (Result<T, APIServiceError>) -> Void) {
        urlSession.dataTask(with: url) { (result)  in
            switch result {
            case .success(let (response, data)):
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200..<299 ~= statusCode else {
                    completion(.failure(.invalidResponse))
                    return
                }
                do {
                    //print("T: \(T.self)")
                    let values = try self.jsonDecoder.decode(T.self, from: data)
                    completion(.success(values))
                } catch {
                    completion(.failure(.decodeError))
                }
            case .failure(let error):
                print("error: \(error)")
                completion(.failure(.apiError))
            }
        }.resume()
    }
}

