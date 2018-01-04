//
//  APIHandler.swift
//  randomPicker
//
//  Created by user131167 on 12/26/17.
//  Copyright © 2017 user131167. All rights reserved.
//

import Foundation
import UIKit

let apiHandler = APIHandler()

class APIHandler {
    let session: URLSession
    let APIKey: String
    
    init() {
        self.APIKey = "aIhekOszLNEcTznDI7LeLf4ORuM6RYlkGxln45dbnLrsoPiWwnXhpDu_Ij7WRo5wiQip7VGN7uDYQbdNWF159f9ZttYnyTknlSL2G3pv9cAwh66CqSGKiphXLINFWnYx"
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["Authorization": "Bearer \(self.APIKey)"]
        let session = URLSession(configuration: configuration)
        self.session = session
    }
    
    func findRestaurant(categories: String?, location: String, radius: String?, price: String?, completionHandler completion: @escaping (restaurant?, Error?) -> Void) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.yelp.com"
        components.path = "/v3/businesses/search"
        
        var queryItems: [URLQueryItem] = []
        
        //TODO: Parse categories
        let queryCategories = URLQueryItem(name: "categories", value: categories)
        queryItems.append(queryCategories)
        //let queryTerm = URLQueryItem(name: "term", value: "food")
        //queryItems.append(queryTerm)
        let queryLocation = URLQueryItem(name: "location", value: location)
        queryItems.append(queryLocation)
        if let rad = radius{
            let queryRadius = URLQueryItem(name: "radius", value: "\(rad)")
            queryItems.append(queryRadius)
        }
        let queryLimit = URLQueryItem(name: "limit", value: "30")
        queryItems.append(queryLimit)
        if let priceVal = price {
            let queryPrice = URLQueryItem(name: "price", value: priceVal)
            queryItems.append(queryPrice)
        }
        
        components.queryItems = queryItems
        let queryURL = components.url!
        print(queryURL)

        let request = URLRequest(url: queryURL)
        
        let dataTask = session.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                //Handle request failed
                print("Request Failed")
                completion(nil, error)
                return
            }
            
            if httpResponse.statusCode == 200 {
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
                        currentRestaurant.update(with: json!, atIndex: 0)
                        completion(currentRestaurant, nil)
                    }
                    catch {
                        print("No Data")
                        completion(nil, error)
                    }
                }
                else {
                    //Handle invalid data
                    print("Invalid Data")
                    completion(nil, error)
                }
            }
            else {
                //Handle bad response
                print("Bad response")
                print(httpResponse.statusCode)
                completion(nil, error)
            }
        }
        dataTask.resume()
    }
    
    func findCategories(for category: String, completionHandler completion: @escaping (String?, Error?) -> Void) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.yelp.com"
        components.path = "/v3/autocomplete"
        var queryItems: [URLQueryItem] = []
        
        let queryText = URLQueryItem(name: "text", value: category)
        queryItems.append(queryText)
        
        components.queryItems = queryItems
        let queryURL = components.url!
        print(queryURL)
        
        let request = URLRequest(url: queryURL)
        
        let dataTask = session.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                //Handle request failed
                print("Request Failed")
                completion(nil, error)
                return
            }
            
            if httpResponse.statusCode == 200 {
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
                        guard let res = json?["categories"] as? [AnyObject] else {
                            completion(nil, error)
                            return
                        }
                        
                        //TODO: iterate over res and create cateory string
                        let aliasStrings: [String] = res.map { obj in
                            obj["alias"] as! String
                        }
                        
                        let resultString = aliasStrings.joined(separator: ",")
                        
                        completion(resultString, nil)
                    }
                    catch {
                        print("No Data")
                        completion(nil, error)
                    }
                }
                else {
                    //Handle invalid data
                    print("Invalid Data")
                    completion(nil, error)
                }
            }
            else {
                //Handle bad response
                print("Bad response")
                print(httpResponse.statusCode)
                completion(nil, error)
            }
        }
        dataTask.resume()
    }
    
    func downloadImage(url: String, completionHandler completion: @escaping (UIImage?, Error?) -> Void) {
        guard let image_url = URL(string: url) else {
            completion(nil, nil)
            return
        }
        print(image_url)
        let request = URLRequest(url: image_url)
        
        let dataTask = session.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                //Handle request failed
                print("Request Failed")
                completion(nil, error)
                return
            }
            
            if httpResponse.statusCode == 200 {
                if let data = data {
                    let image = UIImage(data: data)
                    completion(image, nil)
                }
                else {
                    //Handle invalid data
                    print("Invalid Data")
                    completion(nil, error)
                }
            }
            else {
                //Handle bad response
                print("Bad response")
                print(httpResponse.statusCode)
                completion(nil, error)
            }
        }
        dataTask.resume()
    }
}


