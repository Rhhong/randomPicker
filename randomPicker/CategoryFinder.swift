//
//  CategoryFinder.swift
//  randomPicker
//
//  Created by user131167 on 12/29/17.
//  Copyright © 2017 user131167. All rights reserved.
//

import Foundation

let categoryFinder = CategoryFinder()

class CategoryFinder {
    var categoryList: [[String: AnyObject]]
    var categoryString: String?
    
    //Takes an argument of a space delimited string of categories
    init?() {
        guard let path = Bundle.main.path(forResource: "categories", ofType: "json") else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: [])
            guard let list = jsonResult as? [[String: AnyObject]] else {return nil}
            self.categoryList = list
            //self.stringToFind = categories
            self.categoryString = nil
        }
        catch {
            //Handle error
            return nil
        }
        
        print(categoryList.count)
    }
    
    func search(for category: String) {
        searchFromFile(for: category)
        
        if self.categoryString == nil {
            searchFromAPI(for: category)
        }
    }
    
    func searchFromFile(for category: String) {
        var low = 0
        var high = categoryList.count
        
        while(low < high) {
            let middle: Int = (low + high) / 2
            guard let title = categoryList[middle]["title"] as? String else {return}
            let res = title.caseInsensitiveCompare(category)
            if res == ComparisonResult.orderedSame {
                self.categoryString = categoryList[middle]["alias"] as? String
                return
            }
            else if res == ComparisonResult.orderedAscending {
                low = middle + 1
            }
            else if res == ComparisonResult.orderedDescending {
                high = middle
            }
        }
    }
    
    func searchFromAPI(for category: String) {
        apiHandler.findCategories(for: category) { res, error in
            if let resultString = res {
                self.categoryString = resultString
            }
            else {
                print("Error: \(error)")
            }
        }
    }
    
}
