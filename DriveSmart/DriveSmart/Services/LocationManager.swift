import Foundation
import CoreLocation
import MapKit

import Foundation
import CoreLocation
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var currentLocation: CLLocation?
    
    private let locationManager = CLLocationManager()
    private let geoCoder = CLGeocoder()
    
    override init() {
        super.init()
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.distanceFilter = 10 // Only updates if the user moves 10 meters
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways:
            print(#function, "Always access granted for location")
            manager.startUpdatingLocation()
            
        case .authorizedWhenInUse:
            print(#function, "Foreground access granted for location")
            manager.startUpdatingLocation()
            
        case .notDetermined, .denied:
            print(#function, "Location permission: \(manager.authorizationStatus)")
            manager.stopUpdatingLocation()
            manager.requestWhenInUseAuthorization()
            
        case .restricted:
            print(#function, "Location permission restricted")
            manager.requestAlwaysAuthorization()
            manager.requestWhenInUseAuthorization()
            
        @unknown default:
            print(#function, "Location permission not received")
            manager.stopUpdatingLocation()
            manager.requestWhenInUseAuthorization()
        }
    }
    
    // To receive changes in location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.isEmpty {
            print(#function, "No location received")
        } else {
            if let latestLocation = locations.last {
                print(#function, "Most recent location: \(latestLocation)")
                self.currentLocation = latestLocation
            } else {
                print(#function, "Previously known location: \(String(describing: locations.first))")
                self.currentLocation = locations.first
            }
            print(#function, "Current location: \(String(describing: self.currentLocation))")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function, "Unable to receive location changes due to error: \(error)")
    }
}
