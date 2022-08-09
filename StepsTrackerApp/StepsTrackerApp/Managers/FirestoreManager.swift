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
    
//    weak var delegate:  RetrieveTripsDelegate?
    var retrievedTrips = [Trip](repeating: Trip(), count: 0)
    
    var db: Firestore!
    
    func configureFirebase() {
        // [START setup]
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
    }
    
    func getTripDocuments(completion: @escaping (_ trips: [Trip])->()) {
        
        db.collection("Trips").getDocuments() { (querySnapshot, err) in
            self.retrievedTrips = [Trip](repeating: Trip(), count: querySnapshot!.documents.count + 1)
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for (index, document) in querySnapshot!.documents.enumerated() {
                    print("\(document.documentID) => \(document.data())")
                    do{
                        self.retrievedTrips[index] = try document.data(as: Trip.self)
                    }catch{
                        print(error)
                    }
                }
            }
//            self.delegate?.finishRetrieveTrips()
            completion(self.retrievedTrips)
        }
    }
    
    func addTripToFirebase(trip: Trip) {
        
        
        let collectionRef = db.collection("Trips")
        do {
            let newDocReference = try collectionRef.addDocument(from: trip)
            print("Book stored with new document reference: \(newDocReference)")
        }
        catch {
            print(error)
        }
    }
    
    func addTripToFirebasee(number: Int, firstLocationLongitude: CLLocationDegrees?, firstLocationLatitude: CLLocationDegrees?, lastLocationLongitude: CLLocationDegrees?,  lastLocationLatitude: CLLocationDegrees?, distance: Int, stepsCount: Int) {
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
    
//    func getRetrievedTrips() {
//        configureFirebase()
//        getTripDocuments(completion: () -> ())
//        //        return retrievedTrips
//    }
    
    
    
}


//protocol RetrieveTripsDelegate: AnyObject {
//    func finishRetrieveTrips()
//}
