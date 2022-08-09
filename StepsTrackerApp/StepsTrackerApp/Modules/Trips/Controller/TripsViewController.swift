//
//  ViewController.swift
//  StepsTrackerApp
//
//  Created by Gado on 19/07/2022.
//

import UIKit
import CoreMotion
import CoreLocation
import FirebaseFirestore


class TripsViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var tripsTableView: UITableView!
    
    
    // MARK: - Properties
    
    let firestoreManager = FirestoreManager()
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
    var locationsArray = [GeoPoint]()
    
    
    // MARK: - Override Functions
    // viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configuration()
        configureLocation()
        getRetrievedTripsFirestore()
        startStepsCountUpdating()
    }
    
    // MARK: - Actions
    
    
    
    // MARK: - Methods
    
    func configuration(){
        let nib = UINib(nibName: TripTableViewCell.identifier, bundle: nil)
        tripsTableView.register(nib, forCellReuseIdentifier: TripTableViewCell.identifier)
        tripsTableView.delegate = self
        tripsTableView.dataSource = self
        tripsTableView.rowHeight = 100
    }
    
    func getRetrievedTripsFirestore() {
        
//        firestoreManager.delegate = self
        firestoreManager.configureFirebase()
        firestoreManager.getTripDocuments {trips in
            self.trips = trips
            self.tripsTableView.reloadData()
            print(self.trips.count)
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
                    self?.firestoreManager.addTripToFirebase(trip: self?.fillCurrentTrip() ?? Trip())
                    
                    self?.stopStepsCountUpdating()
                    self?.getRetrievedTripsFirestore()
                    self?.startStepsCountUpdating()
                    
                }
            }
        }
    }
    
    func startCountingSteps(){
        
        
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
    
    
    func navigateToMap(of number: Int) {
        let mapViewController = (self.storyboard?.instantiateViewController(withIdentifier: "mapViewController") as? MapViewController)!
        fillCurrentTrip()
        mapViewController.currentTrip = trips[number - 1]
        //        mapViewController.currentTripNumber = number
        self.navigationController?.pushViewController(mapViewController, animated: true)
    }
    
    func fillCurrentTrip() -> Trip?{
        
        guard let firstLocationLongitude = locationsArray.first?.longitude else { return  nil}
        guard let firstLocationLatitude = locationsArray.first?.latitude else { return  nil}
        guard let lastLocationLongitude = locationsArray.last?.longitude else { return  nil}
        guard let lastLocationLatitude = locationsArray.last?.latitude else { return  nil}
        trips[trips.count - 1].locations = locationsArray
        trips[trips.count - 1].distanceInMeters = distance
        trips[trips.count - 1].stepsCount = stepsCount
        trips[trips.count - 1].id = "Trip\((trips.count) + 1)"
        trips[trips.count - 1].tripNumber = (trips.count) + 1
        
        return trips[trips.count - 1]
        
        
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
        locationsArray.append(GeoPoint(latitude: locValue.latitude, longitude: locValue.longitude))
        print(locationsArray.count)
        
    }
    
    
}

//extension TripsViewController: RetrieveTripsDelegate{
//    func finishRetrieveTrips() {
//        self.trips = firestoreManager.retrievedTrips
//        self.tripsTableView.reloadData()
//        print(trips.count)
//        
//    }
//    
//}

