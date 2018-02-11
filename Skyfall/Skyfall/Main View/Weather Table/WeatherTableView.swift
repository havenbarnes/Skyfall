//
//  WeatherTableView.swift
//  Skyfall
//
//  Created by Haven Barnes on 2/10/18.
//  Copyright © 2018 Azing. All rights reserved.
//

import UIKit
import SwiftyJSON

class WeatherTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    var weatherData: WeatherData!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    

}
