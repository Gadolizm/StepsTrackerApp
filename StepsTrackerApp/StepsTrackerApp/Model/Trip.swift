//
//  Trip.swift
//  StepsTrackerApp
//
//  Created by Gado on 28/07/2022.
//

import UIKit

struct Trip: Codable {
    
    var tripNumber: Int?
    var firstLocationLongitude: Double?
    var firstLocationLatitude: Double?
    var lastLocationLongitude: Double?
    var lastLocationLatitude: Double?
    var distanceInMeters: Int?
    var stepsCount: Int?


}
