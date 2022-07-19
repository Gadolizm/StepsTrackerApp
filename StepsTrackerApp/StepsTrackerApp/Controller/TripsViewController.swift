//
//  ViewController.swift
//  StepsTrackerApp
//
//  Created by Gado on 19/07/2022.
//

import UIKit
import CoreMotion

class TripsViewController: UIViewController {
    
    // MARK:- Outlets
    
    @IBOutlet weak var tripsTableView: UITableView!
    
    
    // MARK:- Properties
    
    let activityManager = CMMotionActivityManager()
    let pedoMeter = CMPedometer()
    var count = "0"{
        didSet{
            tripsTableView.reloadData()
        }
    }
    
    // MARK:- Override Functions
    // viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configuration()
        coreMotionConfiguration()
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
    
    private func coreMotionConfiguration(){
        
        if CMMotionActivityManager.isActivityAvailable(){
            self.activityManager.startActivityUpdates(to: OperationQueue.main) { (data) in
                DispatchQueue.main.async {
                    if let activity = data {
                        if activity.running == true {
                            print("Running")
                        }else if activity.walking == true {
                            print("Walking")
                        }else if activity.automotive == true {
                            print("Automative")
                        }
                    }
                }
            }
        }
        
        if CMPedometer.isStepCountingAvailable(){
            
            self.pedoMeter.startUpdates(from: Date()) { (data, error) in
                if error == nil {
                    if let response = data {
                        DispatchQueue.main.async {
                            print("Number Of Steps == \(response.numberOfSteps)")
                            
                            self.count = "\(response.numberOfSteps.intValue)"
                        }
                    }
                }
            }
        }
        
    }
    
    
    
}


extension TripsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TripTableViewCell.identifier, for: indexPath) as! TripTableViewCell
        cell.tripTableCellLabel.text = count
        return cell
        
    }
    
    
}

