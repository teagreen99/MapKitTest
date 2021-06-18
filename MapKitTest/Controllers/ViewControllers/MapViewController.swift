//
//  MapViewController.swift
//  MapKitTest
//
//  Created by Jaymond Richardson on 6/15/21.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        mapView.delegate = self
        
    }
    //MARK: - Actions
    @IBAction func searchButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Use This Location?", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            
        }
        let yesAction = UIAlertAction(title: "Continue", style: .default) { _ in
            self.performSegue(withIdentifier: "toMadeIt", sender: self)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(yesAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func appleMapsPressed(_ sender: Any) {
        guard let locValue: CLLocationCoordinate2D = locationManager.location?.coordinate else {return} //user current location
        let areaLat = locValue.latitude
        let areaLon = locValue.longitude
        let area = "\(areaLat)\(areaLon)"
        let mapsURL = "http://maps.apple.com/?ll="
        let finalURL = "\(mapsURL)\(area)"
        
        if (UIApplication.shared.canOpenURL(URL(string:"http://maps.apple.com")!)) {
            UIApplication.shared.open(URL(string: "\(finalURL)")!)
            print(finalURL)
            
        } else {
            NSLog("Can't use Apple Maps");
        }
        
    }
    @IBAction func googleMapsPressed(_ sender: Any) {
        
        let locLat : String = "23.035007"
        let locLong : String = "72.529324"
        
        
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            UIApplication.shared.open(URL(string:"comgooglemaps://?saddr=&daddr=\(locLat),\(locLong)&directionsmode=driving")!)
        }
        else {
            print("Can't use comgooglemaps://");
        }
    }
    
    
    //MARK: - Properties
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000
    var previousLocation: CLLocation?
    
 //MARK: - Location Services
    
    
    func setupLocationManager() {
//        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            let alert = UIAlertController(title: "User Location", message: "To allow user location, go to Settings -> Privacy -> Location", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            startTackingUserLocation()
        case .denied:
            let alert = UIAlertController(title: "User Location", message: "To allow user location, go to Settings -> Privacy -> Location", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            let alert = UIAlertController(title: "Location Error", message: "Location resitricted. Change in settings. Privacy -> Location Services", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            break
        case .authorizedAlways:
            break
        @unknown default:
            break
        }
    }
    
    func startTackingUserLocation() {
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        print("\(latitude)\(longitude)")

        return CLLocation(latitude: latitude, longitude: longitude) //Take this data and push to search view to search this area for restaurants
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
}


extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        guard let previousLocation = self.previousLocation else { return }
        
        guard center.distance(from: previousLocation) > 50 else { return }
        self.previousLocation = center
        
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let _ = error {
                let alert = UIAlertController(title: "Error", message: "There was an error fetching the location", preferredStyle: .alert)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            guard let placemark = placemarks?.first else {
                let alert = UIAlertController(title: "Error", message: "There was an error fetching the location", preferredStyle: .alert)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            let streetNumber = placemark.location?.coordinate.latitude//.subThoroughfare ?? ""
            let streetName = placemark.location?.coordinate.longitude//.thoroughfare ?? ""
            
            DispatchQueue.main.async {
                self.addressLabel.text = "\(String(describing: streetNumber)) \(String(describing: streetName))"
            }
        }
    }
}//End of extension

//MARK: - END OF DAY NOTES 6.15.21
/*
Set a search radius around the created pin
 Create a pin on a zip code ///get the lat and lon of zip code
 Send location data to detail view
 Construct URL to take in given lat and long to get directions in apple or google maps
 
 
 */
