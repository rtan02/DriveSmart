//Created by: Melissa Munoz

import Foundation
import CoreLocation
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var currentLocation: CLLocation?
    @Published var currentSpeed: Double = 0.0 // Speed in meters per second
    
    private let locationManager = CLLocationManager()
    private let geoCoder = CLGeocoder()
    
    @Published var speedLimit: Double = 30.0 // Default speed limit in km/h
    
    override init() {
        super.init()
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = 10 // Only updates if the user moves 10 meters
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .notDetermined, .denied, .restricted:
            manager.stopUpdatingLocation()
            manager.requestWhenInUseAuthorization()
        @unknown default:
            manager.stopUpdatingLocation()
            manager.requestWhenInUseAuthorization()
        }
    }
    
    // To receive changes in location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else {
            print(#function, "No location received")
            return
        }
        
        self.currentLocation = latestLocation
        self.currentSpeed = max(latestLocation.speed, 0.0) // Convert m/s to km/h
        
        print(#function, "Current location: \(latestLocation), Speed: \(currentSpeed) m/s")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function, "Unable to receive location changes due to error: \(error)")
    }
}

