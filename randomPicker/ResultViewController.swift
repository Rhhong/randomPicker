//
//  ResultViewController.swift
//  randomPicker
//
//  Created by user131167 on 12/27/17.
//  Copyright © 2017 user131167. All rights reserved.
//

import UIKit
import MapKit

class ResultViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingView: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mapButton.titleLabel?.adjustsFontSizeToFitWidth = true;
        
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        //Map config
        if let location = currentRestaurant.coordinates {
            let regionRadius: CLLocationDistance = 1000
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
            mapView.setRegion(coordinateRegion, animated: true)
            
            let artwork = Artwork(title: currentRestaurant.name, coordinate: location.coordinate)
            mapView.addAnnotation(artwork)
        }
        
        ratingView.image = currentRestaurant.rating_image
        nameLabel.text = currentRestaurant.name
        distanceLabel.text = "\(currentRestaurant.distance) mi."
        reviewLabel.text = "Reviews: \(currentRestaurant.reviewCount)"
        priceLabel.text = "Price: \(currentRestaurant.price)"
        imageView.image = currentRestaurant.image
        mapButton.setTitle(currentRestaurant.location, for: .normal)
        
        scrollToTop()
    }
    
    func scrollToTop() {
        let desiredOffset = CGPoint(x: 0, y: -scrollView.contentInset.top)
        scrollView.setContentOffset(desiredOffset, animated: true)
    }
    
    @IBAction func openMaps(_ sender: UIButton) {
        guard let coord = currentRestaurant.coordinates?.coordinate else {return}
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coord, addressDictionary:nil))
        mapItem.name = "Target location"
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    @IBAction func openYelp(_ sender: UIButton) {
        print(currentRestaurant.url)
        guard let url = URL(string: currentRestaurant.url) else {return}
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func findAnother(_ sender: UIButton) {
        currentRestaurant.chooseRandomRestaurant()
        
        apiHandler.downloadImage(url: currentRestaurant.image_url) { res, error in
            if let download = res {
                currentRestaurant.image = download
                DispatchQueue.main.async {
                    self.loadData()
                }
            }
            else {
                print("error downloading image")
                currentRestaurant.image = nil
            }
        }
    }
    
    @IBAction func editSearch(_ sender: UIButton) {
    }
    
}
