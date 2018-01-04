//
//  RestaurantModel.swift
//  randomPicker
//
//  Created by user131167 on 12/27/17.
//  Copyright © 2017 user131167. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

let currentRestaurant = restaurant()

class restaurant {
    var businesses: [AnyObject]
    
    var name: String
    var image_url: String
    var image: UIImage?
    var url: String
    var rating: String
    var rating_image: UIImage?
    var reviewCount: String
    var price: String
    var phone: String
    var location: String
    var coordinates: CLLocation?
    var distance: String
    
    init() {
        businesses = []
        name = ""
        image_url = ""
        image = nil
        url = ""
        rating = ""
        rating_image = nil
        reviewCount = ""
        price = ""
        phone = ""
        location = ""
        coordinates = nil
        distance = ""
    }
    
    func update(with json: [String: AnyObject], atIndex ind: Int) {
        guard let business = json["businesses"] as? [AnyObject] else {return}
        self.businesses = business
        
        chooseRandomRestaurant()
    }
    
    func chooseRandomRestaurant() {
        let randomIndex:Int = Int(arc4random_uniform(UInt32(businesses.count)))
        
        guard let name = self.businesses[randomIndex]["name"] as? String,
            let image_url = self.businesses[randomIndex]["image_url"] as? String,
            let url = self.businesses[randomIndex]["url"] as? String,
            let rating = self.businesses[randomIndex]["rating"] as? Double,
            let reviewCount = self.businesses[randomIndex]["review_count"] as? Int,
            let price = self.businesses[randomIndex]["price"] as? String,
            let phone = self.businesses[randomIndex]["phone"] as? String,
            let location = self.businesses[randomIndex]["location"] as? [String: AnyObject],
            let coordinates = self.businesses[randomIndex]["coordinates"] as? AnyObject,
            var distance = self.businesses[randomIndex]["distance"] as? Double else {
                print("Error parsing json")
                return
        }
        
        self.name = name
        self.image_url = image_url
        self.url = url
        self.rating = String(format: "%f", rating)
        
        if rating.isEqual(to: 0.0) {
            self.rating_image = #imageLiteral(resourceName: "rating_0")
        }
        else if rating.isEqual(to: 1.0) {
            self.rating_image = #imageLiteral(resourceName: "rating_1")
        }
        else if rating.isEqual(to: 1.5) {
            self.rating_image = #imageLiteral(resourceName: "rating_1_half")
        }
        else if rating.isEqual(to: 2.0) {
            self.rating_image = #imageLiteral(resourceName: "rating_2")
        }
        else if rating.isEqual(to: 2.5) {
            self.rating_image = #imageLiteral(resourceName: "rating_2_half")
        }
        else if rating.isEqual(to: 3.0) {
            self.rating_image = #imageLiteral(resourceName: "rating_3")
        }
        else if rating.isEqual(to: 3.5) {
            self.rating_image = #imageLiteral(resourceName: "rating_3_half")
        }
        else if rating.isEqual(to: 4.0) {
            self.rating_image = #imageLiteral(resourceName: "rating_4")
        }
        else if rating.isEqual(to: 4.5) {
            self.rating_image = #imageLiteral(resourceName: "rating_4_half")
        }
        else if rating.isEqual(to: 5.0) {
            self.rating_image = #imageLiteral(resourceName: "rating_5")
        }
        else {
            self.rating_image = nil
        }
        
        self.reviewCount = String(format: "%d", reviewCount)
        self.price = price
        self.phone = phone
        
        if let displayAddress: [String] = location["display_address"] as? [String] {
            self.location = displayAddress.joined(separator: ", ")
        }
        else {
            self.location = ""
        }
        distance *= 0.000621371
        self.distance = String(format: "%.1f", distance)
        
        guard let latitude = coordinates["latitude"] as? Double, let longitude = coordinates["longitude"] as? Double else {
            return
        }
        self.coordinates = CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func printRestaurant() {
        print("Name: \(self.name)")
        print("URL: \(self.url)")
        print("Image_url: \(self.image_url)")
        print("Rating: \(self.rating)")
        print("Review Count: \(self.reviewCount)")
        print("Price: \(self.price)")
        print("Phone: \(self.phone)")
        print("location: \(self.location)")
        print("Distance: \(self.distance)")
    }
}


