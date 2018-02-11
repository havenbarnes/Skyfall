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
import BEMSimpleLineGraph

class WeatherModalView: UIView, BEMSimpleLineGraphDelegate, BEMSimpleLineGraphDataSource {
    
    var location: CLPlacemark?
    var weatherData: JSON!
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var hourlyChartContainer: BEMSimpleLineGraphView!
    @IBOutlet weak var dailyChartContainer: BEMSimpleLineGraphView!
    
    func load(lat: Float, long: Float, completion: @escaping () -> ()) {
        let geoLocation = CLLocation(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long))
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(geoLocation,completionHandler: { (placemarks, error) in
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
            
            hourlyChartContainer.colorTop = UIColor.clear
            hourlyChartContainer.colorBottom = UIColor.clear
            hourlyChartContainer.enableBezierCurve = true
            hourlyChartContainer.delegate = self
            hourlyChartContainer.dataSource = self
            
            dailyChartContainer.enableYAxisLabel = true
            dailyChartContainer.colorTop = UIColor.clear
            dailyChartContainer.colorBottom = UIColor.clear
            dailyChartContainer.enableBezierCurve = true
            dailyChartContainer.formatStringForValues = "%.1f"
            dailyChartContainer.delegate = self
            dailyChartContainer.dataSource = self
        }
        
        icon.image = UIImage(named: weatherData["currently"]["icon"].stringValue)
        tempLabel.text = "\(String(describing: Int(Float((weatherData["currently"]["temperature"].stringValue))!)))º"
        highLabel.text = "H \(String(describing: Int(Float(weatherData["daily"]["data"][0]["temperatureHigh"].stringValue)!)))"
        lowLabel.text = "L \(String(describing: Int(Float(weatherData["daily"]["data"][0]["temperatureLow"].stringValue)!)))"
        windLabel.text = "\(Float(weatherData["currently"]["windSpeed"].stringValue)!)"
    }
    
    func numberOfPoints(inLineGraph graph: BEMSimpleLineGraphView) -> Int {
        if graph.tag == 0 {
            print(weatherData["minutely"]["data"].count)
            return weatherData["minutely"]["data"].count
        } else {
            print(weatherData["hourly"]["data"].count)
            return weatherData["hourly"]["data"].count
        }
    }
    
    func lineGraph(_ graph: BEMSimpleLineGraphView, valueForPointAt index: Int) -> CGFloat {
        if graph.tag == 0 {
            let data = weatherData["minutely"]["data"].arrayValue[index].dictionaryValue
            return CGFloat(data["precipProbability"]!.doubleValue * 100.0)
        } else {
            let data = weatherData["hourly"]["data"].arrayValue[index].dictionaryValue
            return CGFloat(data["precipProbability"]!.doubleValue * 100.0)
        }
    }
    
    func lineGraph(_ graph: BEMSimpleLineGraphView, labelOnXAxisFor index: Int) -> String? {
        if graph.tag == 0 {
            let data = weatherData["minutely"]["data"].arrayValue[index].dictionaryValue
            return "\((Int(NSDate().timeIntervalSince1970) - data["time"]!.intValue) / 60)"
        } else {
            let data = weatherData["hourly"]["data"].arrayValue[index].dictionaryValue
            return "\((Int(NSDate().timeIntervalSince1970) - data["time"]!.intValue) / 360)"
        }
    }
    
    func baseValueForYAxis(onLineGraph graph: BEMSimpleLineGraphView) -> CGFloat {
        return 0
    }
    
    func incrementValueForYAxis(onLineGraph graph: BEMSimpleLineGraphView) -> CGFloat {
        return 10
    }
    
    func yAxisSuffix(onLineGraph graph: BEMSimpleLineGraphView) -> String {
        return "%"
    }
    
    func noDataLabelEnable(forLineGraph graph: BEMSimpleLineGraphView) -> Bool {
        return true
    }
    
    func noDataLabelText(forLineGraph graph: BEMSimpleLineGraphView) -> String {
        if graph.tag == 0 {
            return "No minute-by-minute data for this location"
        }
        return "No hour-by-hour data for this location"
    }
    
    func numberOfYAxisLabels(onLineGraph graph: BEMSimpleLineGraphView) -> Int {
        return 5
    }
    
    @IBAction func timeMachineButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func downButtonPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.3, animations: {
            self.frame.origin.y = self.superview!.frame.height
        }) { (complete) in
            self.removeFromSuperview()
        }
    }
}
