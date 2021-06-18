//
//  Locations.swift
//  MapKitTest
//
//  Created by Jaymond Richardson on 6/16/21.
//

import UIKit
import CoreLocation

class LocationPickerController {
    
    //MARK: - Shared Instance
    static let shared = LocationPickerController()
    
    //MARK: - Source of Truth
    var searchLocation: CLLocation?
     
    var myLocation: CLLocation? {
        didSet {
                searchLocation = myLocation
                // Print statement to watch reporting of locations in console
                print(myLocation!.coordinate.latitude.description)
        }
    }
}//End of class
