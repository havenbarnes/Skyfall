//
//  Nasa.swift
//  MarsArchive
//
//  Created by Haven Barnes on 2/3/17.
//  Copyright © 2017 Azing. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class DarkSky {
    
    var failedAttempts = 0
    
    static let apiKey = "a16c9349c0de8e8276a3cab816ac095e"
    static let baseUrl = "https://api.darksky.net/forecast/\(apiKey)/"
    
    
    enum Endpoint {
        case forecast(String, String) // Latitude, Longitude
        case timeMachine(String, String, String) // Latitude, Longitude, Time
    }
    
    enum Options {
        case exclude(String)
    }
    
    private func url(for endpoint: Endpoint, with options: [Options]?) -> String {
        var url = DarkSky.baseUrl
        switch endpoint {
        case .forecast(let latitude, let longitude):
            url += "\(latitude),\(longitude)"
        case .timeMachine(let latitude, let longitude, let time):
            url += "\(latitude),\(longitude),\(time)"
        }
        return url
    }
    
    func fetch(endpoint: Endpoint, options: [Options]?, completion: @escaping ((JSON?) throws -> Void)) {
        let url = self.url(for: endpoint, with: options)
        print(url)
        Alamofire.request(url)
            .responseJSON { response in
                
                let json = try? JSON(data: response.data!)
                try? completion(json)
        }
        
    }
}
