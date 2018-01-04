//
//  ViewController.swift
//  randomPicker
//
//  Created by user131167 on 12/26/17.
//  Copyright © 2017 user131167. All rights reserved.
//

import UIKit
import CoreLocation

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

class SearchViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
	
    @IBOutlet weak var keywordLabel: UITextField!
    @IBOutlet weak var locationLabel: UITextField!
    @IBOutlet weak var radiusLabel: UITextField!
    @IBOutlet weak var priceLabel: UITextField!
    @IBOutlet weak var pricePicker: UIPickerView!
    @IBOutlet weak var pickerDoneButton: UIButton!
    
    let priceOptions = ["","$","$$","$$$","$$$$"]
    let priceString: [String: String] = ["$":"1","$$":"2","$$$":"3","$$$$":"4"]
    
    let locationManager = CLLocationManager()
    
    @IBAction func Search(_ sender: UIButton) {
        guard let categories: String = categoryFinder!.categoryString else {
            let myAlert = UIAlertController(title: "Alert", message: "Please enter a keyword.", preferredStyle: .alert)
            myAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            self.present(myAlert, animated: true, completion: nil)
            return
        }
        print("Categories: \(categories)")
        var location: String
        
        var radius: String? = nil
        if !radiusLabel.text!.isEmpty {
            radius = radiusLabel.text
            if let rad = Int(radius!), let radiusInMeters: Int = rad * 1600 {
                if rad > 0 && rad <= 25 {
                    radius = String(describing: radiusInMeters)
                }
                else {
                    let myAlert = UIAlertController(title: "Alert", message: "Please enter a number between 0 and 25.", preferredStyle: .alert)
                    myAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    self.present(myAlert, animated: true, completion: nil)
                    return
                }
            }
            else {
                let myAlert = UIAlertController(title: "Alert", message: "Please enter a valid radius.", preferredStyle: .alert)
                myAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                self.present(myAlert, animated: true, completion: nil)
                return
            }
        }
        print("Radius: \(radius)")
        
        var price: String? = nil
        if !priceLabel.text!.isEmpty {
            price = priceString[priceLabel.text!]
        }
        print("Price: \(price)")
        
        if let locText = locationLabel.text, !locText.isEmpty {
            location = locText
        }
        else {
            guard let loc = locationManager.location else {return}
            let latitude = loc.coordinate.latitude
            let longitude = loc.coordinate.longitude
            location = "\(latitude),\(longitude)"
        }
        print("Location: \(location)")
        
        apiHandler.findRestaurant(categories: categories, location: location, radius: radius, price: price) { res, error in
            if let restaurant = res {
                restaurant.printRestaurant()
                apiHandler.downloadImage(url: restaurant.image_url) { res, error in
                    if let download = res {
                        currentRestaurant.image = download
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "search", sender: sender)
                        }
                    }
                    else {
                        print("error downloading image")
                        currentRestaurant.image = nil
                    }
                }
            }
            else {
                print("Error: \(error)")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.hideKeyboardWhenTappedAround()
        
        keywordLabel.delegate = self
        locationLabel.delegate = self
        radiusLabel.delegate = self
        priceLabel.delegate = self
        pricePicker.delegate = self
        
        //Location Services
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            locationManager.startUpdatingLocation()
        }
        
        //Manage price picker
        
        pricePicker.isHidden = true
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "search" {
            print("launching segue")
            if let destination = segue.destination as? ResultViewController {
                //destination.currentRestaurant = self.currentRestaurant
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.denied) {
            showLocationDisabledPopUp()
        }
    }
    
    func showLocationDisabledPopUp() {
        let alertController = UIAlertController(title: "Background Location Access Disabled",
                                                message: "In order to make suggestions we need your location",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("\(textField)")
        if textField == keywordLabel {
            if let str = keywordLabel.text, let finder = categoryFinder {
                finder.search(for: str)
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 5
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return priceOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        priceLabel.text = priceOptions[row]
        //pricePicker.isHidden = true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == priceLabel {
            pricePicker.isHidden = false
            pickerDoneButton.isHidden = false
            //self.view.bringSubview(toFront: pricePicker)
            return false
        }
        return true
    }
    
    @IBAction func pickerDoneButtonPressed(_ sender: UIButton) {
        pricePicker.isHidden = true
        pickerDoneButton.isHidden = true
    }
}

