//
//  WeatherModalView.swift
//  Skyfall
//
//  Created by Haven Barnes on 2/10/18.
//  Copyright © 2018 Azing. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation

class WeatherModalView: UIView {
    
    var location: CLPlacemark?
    var weatherData: JSON!
    
    @IBOutlet weak var cityLabel: UILabel!
    
    func load(lat: Float, long: Float, completion: @escaping () -> ()) {
        let geoLocation = CLLocation(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long))
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(geoLocation,
                                        completionHandler: { (placemarks, error) in
                                                self.location = placemarks?[0]
                                                self.setupUI()
                                                completion()
                            
        })
    }
    
    func setupUI() {
        if location != nil {
            cityLabel.text = ""
            if location!.locality != nil {
                cityLabel.text = location!.locality!
            }
            if location!.country != nil {
                if cityLabel.text != "" {
                    cityLabel.text = cityLabel.text! + ", "
                }
                cityLabel.text = cityLabel.text! + location!.country!
            }
        }
    }
    
    @IBAction func downButtonPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.3, animations: {
            self.frame.origin.y = self.superview!.frame.height
        }) { (complete) in
            self.removeFromSuperview()
        }
    }
}
