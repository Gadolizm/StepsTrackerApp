//
//  Trip.swift
//  StepsTrackerApp
//
//  Created by Gado on 28/07/2022.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Trip: Codable{
    
    @DocumentID var id: String?
    var tripNumber: Int?
    var locations: [GeoPoint]?
    var distanceInMeters: Int?
    var stepsCount: Int?


}
