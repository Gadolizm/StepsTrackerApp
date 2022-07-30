//
//  ViewController.swift
//  StepsTrackerApp
//
//  Created by Gado on 19/07/2022.
//

import UIKit
import CoreMotion
import CoreLocation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

class TripsViewController: UIViewController {
    
    // MARK:- Outlets
    
    @IBOutlet weak var tripsTableView: UITableView!
    
    
    // MARK:- Properties
    
    var db: Firestore!
    let activityManager = CMMotionActivityManager()
    let launchDate = UserDefaults.standard.object(forKey: "latestLaunchDate") as? Date
    let pedoMeter = CMPedometer()
    
    var stepsCount = 0{
        didSet{
            tripsTableView.reloadData()
        }
    }
    
    var distance = 0{
        didSet{
            tripsTableView.reloadData()
        }
    }
    var trips = [Trip]()
    let locationManager = CLLocationManager()
    var locationsArray = [CLLocationCoordinate2D]()
    
    
    
    
    // MARK:- Override Functions
    // viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configuration()
        configureFirebase()
        getTripDocuments()
        configureLocation()
        startStepsCountUpdating()
    }
    
    // MARK:- Actions
    
    
    
    // MARK:- Methods
    
    private func configuration(){
        let nib = UINib(nibName: TripTableViewCell.identifier, bundle: nil)
        tripsTableView.register(nib, forCellReuseIdentifier: TripTableViewCell.identifier)
        tripsTableView.delegate = self
        tripsTableView.dataSource = self
        tripsTableView.rowHeight = 100
    }
    
    
    func getTripDocuments()  {
        
        db.collection("Trips").getDocuments() { (querySnapshot, err) in
            self.trips = [Trip](repeating: Trip(), count: querySnapshot!.documents.count + 1)
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for (index, document) in querySnapshot!.documents.enumerated() {
                    print("\(document.documentID) => \(document.data())")
                    self.trips[index].tripNumber = document.data()["tripNumber"] as? Int
                    self.trips[index].distanceInMeters = document.data()["distance"] as? Int
                    self.trips[index].stepsCount = document.data()["stepsCount"] as? Int
                    self.trips[index].firstLocationLongitude = document.data()["firstLocationLongitude"] as? Double
                    self.trips[index].firstLocationLatitude = document.data()["firstLocationLatitude"] as? Double
                    self.trips[index].lastLocationLatitude = document.data()["lastLocationLatitude"] as? Double
                    self.trips[index].lastLocationLongitude = document.data()["lastLocationLongitude"] as? Double
                    
                }
            }
            self.tripsTableView.reloadData()
        }
    }
    
    func stopStepsCountUpdating() {
        activityManager.stopActivityUpdates()
        pedoMeter.stopUpdates()
        pedoMeter.stopEventUpdates()
    }
    
    func startStepsCountUpdating() {
        
        distance = 0
        stepsCount = 0
        startTrackingActivityType()
        startCountingSteps()
    }
    //    func pedometerStepsCountUpdate(startDate: Date) {
    //        pedoMeter.queryPedometerData(from: startDate, to: Date()) {
    //            [weak self] pedometerData, error in
    //            if let error = error {
    //                print(error)
    //
    //            } else if let pedometerData = pedometerData {
    //                DispatchQueue.main.async {
    //
    //                }
    //            }
    //        }
    //    }
    
    func check5MinutesStationaryMode() {
        
        let endDate = Date()
        let startDate = endDate.addingTimeInterval(-60 * 5)
        guard let usingAppDuration = self.launchDate?.timeIntervalSince(endDate) else { return }
        if usingAppDuration > 5 * 60 {
            
            self.activityManager.queryActivityStarting(from: startDate, to: endDate, to: OperationQueue.main) { [weak self] motionActivities, error in
                DispatchQueue.main.async {
                    
                    if let error = error {
                        print("error: \(error.localizedDescription)")
                        return
                    }
                    
                    motionActivities?.forEach { activity in
                        
                        if activity.confidence == .medium || activity.confidence == .high {
                            
                            if activity.automotive {
                                print("automotive")
                                return
                            } else if activity.walking {
                                print("walking")
                                return
                            } else if activity.running {
                                print("running")
                                return
                            } else if activity.cycling {
                                print("cycling")
                                
                                return
                            } else {
                                print("---------ok--stoping-----------")
                            }
                            
                        }
                    }
                    self?.addTripToFirebase(number: (self?.trips.count ?? 0) + 1)
                    self?.stopStepsCountUpdating()
                    self?.getTripDocuments()
                    self?.startStepsCountUpdating()
                    
                }
            }
        }
    }
    
    private func startCountingSteps(){
        
        
        if CMPedometer.isStepCountingAvailable(){
            self.pedoMeter.startUpdates(from: Date()) { [weak self] (data, error) in
                if error == nil {
                    if let response = data {
                        DispatchQueue.main.async {
                            print("Number Of Steps == \(response.numberOfSteps)")
                            print("Distance == \(String(describing: response.distance))")
                            self?.stepsCount = response.numberOfSteps.intValue
                            self?.distance = Int(truncating: response.distance ?? 0)
                            
                        }
                    }
                }
            }
        }
        
    }
    
    func startTrackingActivityType() {
        
        
        if CMMotionActivityManager.isActivityAvailable(){
            self.activityManager.startActivityUpdates(to: OperationQueue.main) { [weak self] (data) in
                DispatchQueue.main.async {
                    if let activity = data {
                        if activity.running == true {
                            print("Running")
                        }else if activity.walking == true {
                            print("Walking")
                        }else if activity.automotive == true {
                            print("Automative")
                        } else if activity.cycling == true {
                            print("cycling")
                        }
                        else{
                            
                            self?.check5MinutesStationaryMode()
                        }
                    }
                }
            }
        }
    }
    
    func configureFirebase() {
        // [START setup]
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
    }
    
    
    private func addTripToFirebase(number: Int) {
        guard let firstLocationLongitude = locationsArray.first?.longitude else { return  }
        guard let firstLocationLatitude = locationsArray.first?.latitude else { return  }
        guard let lastLocationLongitude = locationsArray.last?.longitude else { return  }
        guard let lastLocationLatitude = locationsArray.last?.latitude else { return  }
        
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
    
    func navigateToMap(of number: Int) {
        let mapViewController = (self.storyboard?.instantiateViewController(withIdentifier: "mapViewController") as? MapViewController)!
        fillCurrentTrip()
        mapViewController.currentTrip = trips[number - 1]
        //        mapViewController.currentTripNumber = number
        self.navigationController?.pushViewController(mapViewController, animated: true)
    }
    
    func fillCurrentTrip(){
        
        guard let firstLocationLongitude = locationsArray.first?.longitude else { return  }
        guard let firstLocationLatitude = locationsArray.first?.latitude else { return  }
        guard let lastLocationLongitude = locationsArray.last?.longitude else { return  }
        guard let lastLocationLatitude = locationsArray.last?.latitude else { return  }
        trips[trips.count - 1].firstLocationLatitude = firstLocationLatitude
        trips[trips.count - 1].firstLocationLongitude = firstLocationLongitude
        trips[trips.count - 1].lastLocationLatitude = lastLocationLatitude
        trips[trips.count - 1].lastLocationLongitude = lastLocationLongitude
        trips[trips.count - 1].distanceInMeters = distance
        
    }
    
    
    
}


extension TripsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TripTableViewCell.identifier, for: indexPath) as! TripTableViewCell
        if indexPath.row == trips.count - 1 {
            cell.tripTableCellLabel.text = "\(stepsCount)"
            return cell
        } else {
            cell.tripTableCellLabel.text = "\(trips[indexPath.row].stepsCount ?? 0)"
            return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigateToMap(of: indexPath.row + 1)
    }
    
    
}

extension TripsViewController: CLLocationManagerDelegate{
    
    func configureLocation() {
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("location = \(locValue.latitude) \(locValue.longitude)")
        locationsArray.append(locValue)
        print(locationsArray.count)
        
    }
    
    
}

