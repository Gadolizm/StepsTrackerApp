//
//  MapViewController.swift
//  StepsTrackerApp
//
//  Created by Gado on 24/07/2022.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import SwiftyJSON

class MapViewController: UIViewController {
    
    // MARK:- Outlets
    
    @IBOutlet weak var mapView: GMSMapView!
    
    
    // MARK:- Properties
    
    var locationsArray = [CLLocationCoordinate2D]()

    
    // MARK: Define the source latitude and longitude
    
    let sourceLat = 28.704060
    let sourceLng = 77.102493
    
    // MARK: Define the destination latitude and longitude
    
    let destinationLat = 28.459497
    let destinationLng = 77.026634
    
    // MARK: Create source location and destination location so that you can pass it to the URL
    var sourceLocation = ""
    var destinationLocation = ""
    
    // MARK: Create URL
    var url = ""
    
    
    // MARK:- Override Functions
    // viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        configure()
        addPolylineToMap(locations: locationsArray)
        makeMarkers()
    }
    
    // MARK:- Actions
    
    
    
    // MARK:- Methods
    
//    func configure()  {
//
//        sourceLocation = "\(sourceLat),\(sourceLng)"
//        destinationLocation = "\(destinationLat),\(destinationLng)"
//        url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(sourceLocation)&destination=\(destinationLocation)&mode=driving&key=AIzaSyAmQXfv96FE-nFEVyaeYa4E495NNFOb3ew"
//
//    }
    
    
    // MARK: Request for response from the google
    
    func addPolylineToMap(locations: [CLLocationCoordinate2D]) {
        let path = GMSMutablePath()
        locations.forEach{ location in
            path.add(location)
        }

        path.addLatitude(-31.95285, longitude: 115.85734)
        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = .systemBlue
        polyline.strokeWidth = 5
        polyline.geodesic = true
        polyline.map = mapView
    }

    
//    func callGoogleAPI() {
        
        
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
//                    polyline.strokeColor = .systemBlue
//                    polyline.strokeWidth = 5
//                    polyline.map = self.mapView
//                }
//            }
//            catch let error {
//                print(error.localizedDescription)
//            }
//        }
//    }
    
    
    // MARK: Marker for source location
    
    func makeMarkers() {
        
        let sourceMarker = GMSMarker()
        sourceMarker.position = CLLocationCoordinate2D(latitude: locationsArray.first?.latitude ?? 0, longitude: locationsArray.first?.longitude ?? 0)
        sourceMarker.title = "Delhi"
        sourceMarker.snippet = "The Capital of INDIA"
        sourceMarker.map = self.mapView
        
        
        // MARK: Marker for destination location
        let destinationMarker = GMSMarker()
        destinationMarker.position = CLLocationCoordinate2D(latitude: locationsArray.last?.latitude ?? 0, longitude: locationsArray.last?.latitude ?? 0)
        destinationMarker.title = "Gurugram"
        destinationMarker.snippet = "The hub of industries"
        destinationMarker.map = self.mapView
        
        let camera = GMSCameraPosition(target: sourceMarker.position, zoom: 100)
        self.mapView.animate(to: camera)
    }
    
    
}
