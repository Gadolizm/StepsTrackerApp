//
//  FirestoreManager.swift
//  StepsTrackerApp
//
//  Created by Gado on 05/08/2022.
//

import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import CoreLocation


class FirestoreManager {
    
    static let shared = FirestoreManager()
    weak var delegate:  RetrieveTripsDelegate?
    var retrievedTrips = [Trip](repeating: Trip(), count: 0)
    
    var db: Firestore!
    
    func configureFirebase() {
        // [START setup]
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
    }
    
    
    func getTripDocuments() {
        
        db.collection("Trips").getDocuments() { (querySnapshot, err) in
            self.retrievedTrips = [Trip](repeating: Trip(), count: querySnapshot!.documents.count + 1)
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                    for (index, document) in querySnapshot!.documents.enumerated() {
                        print("\(document.documentID) => \(document.data())")
                        self.retrievedTrips[index].tripNumber = document.data()["tripNumber"] as? Int
                        self.retrievedTrips[index].distanceInMeters = document.data()["distance"] as? Int
                        self.retrievedTrips[index].stepsCount = document.data()["stepsCount"] as? Int
                        self.retrievedTrips[index].firstLocationLongitude = document.data()["firstLocationLongitude"] as? Double
                        self.retrievedTrips[index].firstLocationLatitude = document.data()["firstLocationLatitude"] as? Double
                        self.retrievedTrips[index].lastLocationLatitude = document.data()["lastLocationLatitude"] as? Double
                        self.retrievedTrips[index].lastLocationLongitude = document.data()["lastLocationLongitude"] as? Double
                        
                }
            }
            self.delegate?.finishRetrieveTrips()
        }
    }
    
    func addTripToFirebase(number: Int, firstLocationLongitude: CLLocationDegrees?, firstLocationLatitude: CLLocationDegrees?, lastLocationLongitude: CLLocationDegrees?,  lastLocationLatitude: CLLocationDegrees?, distance: Int, stepsCount: Int) {
        guard let firstLocationLongitude = firstLocationLongitude else { return  }
        guard let firstLocationLatitude = firstLocationLatitude else { return  }
        guard let lastLocationLongitude = lastLocationLongitude else { return  }
        guard let lastLocationLatitude = lastLocationLatitude else { return  }
        
        db.collection("Trips").document("Trip\(number)").setData([
            "tripNumber": number,
            "firstLocationLongitude": Double(firstLocationLongitude),
            "firstLocationLatitude": Double(firstLocationLatitude),
            "lastLocationLongitude": Double(lastLocationLongitude),
            "lastLocationLatitude": Double(lastLocationLatitude),
            "distanceInMeters": distance,
            "stepsCount": stepsCount
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    func getRetrievedTrips() {
        configureFirebase()
        getTripDocuments()
//        return retrievedTrips
    }
    
    
    
}


protocol RetrieveTripsDelegate: AnyObject {
    func finishRetrieveTrips()
}
