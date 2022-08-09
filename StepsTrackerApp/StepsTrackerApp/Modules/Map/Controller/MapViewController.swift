//
//  MapViewController.swift
//  StepsTrackerApp
//
//  Created by Gado on 24/07/2022.
//

import UIKit
import GoogleMaps
import GooglePlaces
//import Alamofire
//import SwiftyJSON
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

class MapViewController: UIViewController {
    
    // MARK:- Outlets
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    
    // MARK:- Properties
    
    var db: Firestore!
    var currentTrip: Trip?
//    var currentTripNumber: Int?


    
    // MARK: Create source location and destination location so that you can pass it to the URL
    var sourceLocation = ""
    var destinationLocation = ""
    
    // MARK: Create URL
    var url = ""
    
    
    // MARK:- Override Functions
    // viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
//        getURL()
        addPolylineToMap(locations: currentTrip?.locations ?? [])
//        callGoogleAPI()
        makeMarkers()
//        configureFirebase()
//        getTripDocument()

    }
    
    // MARK:- Actions
    
    
    
    // MARK:- Methods
    
    
    func configureUI()  {
        
        guard let distance = currentTrip?.distanceInMeters else { return }
        distanceLabel.text = "\(String(describing: distance)) m."
    }
    
    func configureFirebase() {
        // [START setup]
        let settings = FirestoreSettings()

        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
    }

    
    
//    func getURL() {
//
//        guard let trip = currentTrip else { return }
//
//        sourceLocation = "\(trip.firstLocationLatitude!),\(trip.firstLocationLongitude!)"
//        destinationLocation = "\(trip.lastLocationLatitude!),\(trip.firstLocationLongitude!)"
//        url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(sourceLocation)&destination=\(destinationLocation)&mode=walking&key=AIzaSyAmQXfv96FE-nFEVyaeYa4E495NNFOb3ew"
//
//    }
    
//    func callGoogleAPI() {
//
//
//        AF.request(url).responseJSON { (response) in
//            print(response.request!)  // original URL request
//             print(response.response!) // HTTP URL response
//             print(response.data!)     // server data
//             print(response.result)   // result of response serialization
//            guard let data = response.data else {
//                return
//            }
//
//            do {
//                let jsonData = try JSON(data: data)
//                let routes = jsonData["routes"].arrayValue
//
//                for route in routes {
//                    let overview_polyline = route["overview_polyline"].dictionary
//                    let points = overview_polyline?["points"]?.string
//                    let path = GMSPath.init(fromEncodedPath: points ?? "")
//                    let polyline = GMSPolyline.init(path: path)
//                    polyline.strokeColor = .black
//                    polyline.geodesic = true
//                    polyline.strokeWidth = 5
//                    polyline.map = self.mapView
//                }
//            }
//            catch let error {
//                print(error.localizedDescription)
//            }
//        }
//    }
    
    
    func addPolylineToMap(locations: [GeoPoint]) {
        let path = GMSMutablePath()
        locations.forEach{ geoPoint in
            let location = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
            path.add(location)
        }

        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = .black
        polyline.strokeWidth = 5
        polyline.geodesic = true
        polyline.map = mapView
    }

    
    
    // MARK: Marker for source location
    
    func makeMarkers() {
        
        let sourceMarker = GMSMarker()
        sourceMarker.position = CLLocationCoordinate2D(latitude: currentTrip?.locations?.first?.latitude ?? 0.0, longitude: currentTrip?.locations?.first?.longitude ?? 0.0)
        sourceMarker.title = "From"
        sourceMarker.snippet = "Beginning"
        sourceMarker.map = self.mapView
        
        
        // MARK: Marker for destination location
        let destinationMarker = GMSMarker()
        destinationMarker.position = CLLocationCoordinate2D(latitude: currentTrip?.locations?.last?.latitude ?? 0.0, longitude: currentTrip?.locations?.last?.longitude ?? 0.0)
        destinationMarker.title = "To"
        destinationMarker.snippet = "End"
        destinationMarker.map = self.mapView
        
        let camera = GMSCameraPosition(target: sourceMarker.position, zoom: 100)
        self.mapView.animate(to: camera)
    }
    
    
}
