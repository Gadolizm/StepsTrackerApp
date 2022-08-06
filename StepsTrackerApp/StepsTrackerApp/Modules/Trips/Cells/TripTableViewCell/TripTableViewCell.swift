//
//  TripTableViewCell.swift
//  StepsTrackerApp
//
//  Created by Gado on 19/07/2022.
//

import UIKit

class TripTableViewCell: UITableViewCell {

    // MARK:- Outlets
    
    @IBOutlet weak var tripTableCellLabel: UILabel!

    
    // MARK:- Properties
    
    static let identifier = "TripTableViewCell"
    
    
    // MARK:- Override Functions
    // viewDidLoad
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK:- Actions
    
    
    // MARK:- Methods
    
}
