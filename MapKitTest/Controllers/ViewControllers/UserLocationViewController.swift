//
//  UserLocationViewController.swift
//  MapKitTest
//
//  Created by Jaymond Richardson on 6/16/21.
//

import UIKit
import MapKit
import CoreLocation

class UserLocationViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var currentLocationCoordinates: UILabel!
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LocationManager.shared.start()
    }
    
    //MARK: - Properties
    var location: CLLocation? {
        didSet {
            loadViewIfNeeded()
            updateViews()
        }
    }

    // TODO: - Need to test and get working
    @IBAction func googleMapsTapped(_ sender: Any) {
        if let locLat = location?.coordinate.latitude.description,
           let locLong = location?.coordinate.longitude.description {
            if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                UIApplication.shared.open(URL(string:"comgooglemaps://?saddr=&daddr=\(locLat),\(locLong)&directionsmode=driving")!)
            }
            else {
                print("Can't use comgooglemaps://");
            }
        }
    }
    
    // apple maps works
    @IBAction func appleMapsTapped(_ sender: Any) {
        if let location = location {
            let endingLat = location.coordinate.latitude
            let endingLon = location.coordinate.longitude
            let startingLat = LocationPickerController.shared.myLocation!.coordinate.latitude
            let startingLon = LocationPickerController.shared.myLocation!.coordinate.longitude
            let directions = "\(startingLat),\(startingLon)&daddr=\(endingLat),\(endingLon)"
            let mapsURL = "http://maps.apple.com/?saddr="
            let finalURL = "\(mapsURL)\(directions)"
            
            if (UIApplication.shared.canOpenURL(URL(string:"http://maps.apple.com")!)) {
                UIApplication.shared.open(URL(string: "\(finalURL)")!)
                print(finalURL)
            } else {
                print("Can't use Apple Maps");
            }
        }
    }
    
    //MARK: - Functions
    func updateViews() {
        guard let location = location else {return}
        currentLocationCoordinates.text = "Lat: \(location.coordinate.latitude.description), \(location.coordinate.longitude.description)"
    }
}
