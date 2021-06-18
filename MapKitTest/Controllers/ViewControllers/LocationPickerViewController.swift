//
//  LocationPickerViewController.swift
//  MapKitTest
//
//  Created by Jaymond Richardson on 6/16/21.
//

import UIKit
import MapKit
import CoreLocation

class LocationPickerViewController: UIViewController {
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        LocationManager.shared.checkLocationServices()
        LocationManager.shared.setDelegate(self)
        LocationManager.shared.start()
    }
    
    // MARK: - Actions
    @IBAction func searchByZipTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "ZIP CODE", message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter 5 digit Zip Code..."
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        let searchAction = UIAlertAction(title: "Search", style: .default) { _ in
            guard let text = alertController.textFields?.first?.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(text) { placemarks, error in
                guard let placemark = placemarks?.first,
                      let coordinates = placemark.location?.coordinate else
                {
                    print("error geocoding")
                    return
                }
                LocationManager.shared.stop()
                LocationPickerController.shared.searchLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
                self.performSegue(withIdentifier: "toUserLocationVC", sender: self)
            }
        }
        alertController.addAction(searchAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUserLocationVC" {
            guard let destinationVC = segue.destination as? UserLocationViewController else { return }
            LocationManager.shared.stop()
            let location  = LocationPickerController.shared.searchLocation
            destinationVC.location = location
        }
    }
    
}//End of class

extension LocationPickerViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            LocationPickerController.shared.myLocation = location
        }
    }
}
