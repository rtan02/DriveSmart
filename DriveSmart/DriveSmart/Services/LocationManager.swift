//Created by: Melissa Munoz

import Foundation
import CoreLocation
import MapKit

struct RouteSegment {
    let latitude: Double
    let longitude: Double
    
    let requiresStop: Bool
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var currentLocation: CLLocation?
    @Published var currentSpeed: Double = 0.0 // Speed in meters per second
    
    private let locationManager = CLLocationManager()
    private let geoCoder = CLGeocoder()
    
    @Published var infractions: [String] = []
    @Published var speedLimit: Double = 40.0 // Default speed limit in km/h
    
    private var currentWaypointIndex = 0
    
    private var previousSpeed: Double = 0.0
    private var previousHeading: CLLocationDirection?
    private let turnSpeedLimit: Double = 20.0 // Speed limit for turns in km/h
    private let suddenSpeedChangeThreshold: Double = 10.0 // km/h
    
    private let route: [RouteSegment] = [
        RouteSegment(latitude: 43.678669,
        longitude: -79.825732,
        requiresStop: true),
        RouteSegment(latitude: 43.680343,
        longitude: -79.824263,
        requiresStop: false),
        RouteSegment(latitude: 43.680018,
        longitude: -79.823688,
        requiresStop: true),
        RouteSegment(latitude: 43.678368,
        longitude: -79.825027,
        requiresStop: true),
        RouteSegment(latitude: 43.678669,
        longitude: -79.825732,
        requiresStop: false),
    ]
    
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
        
        currentLocation = latestLocation
        let currentSpeed = latestLocation.speed >= 0 ? latestLocation.speed * 3.6 : 0.0 // Convert m/s to km/h
        self.currentSpeed = currentSpeed
        
        // Check for speeding
        let globalSpeedLimit = 30.0 // Universal speed limit in km/h
        if currentSpeed > globalSpeedLimit {
            recordInfraction("Speeding: \(Int(currentSpeed)) km/h in a \(Int(globalSpeedLimit)) km/h zone")
        }
        
        // Check for sudden speed changes
        let speedDifference = abs(currentSpeed - previousSpeed)
        if speedDifference > suddenSpeedChangeThreshold {
            let type = currentSpeed > previousSpeed ? "Acceleration" : "Braking"
            recordInfraction("Sudden \(type): Speed changed by \(Int(speedDifference)) km/h")
        }
        previousSpeed = currentSpeed
        
        
        // Check for excessive speed on turns
        if let previousHeading = previousHeading {
            let headingDifference = abs(latestLocation.course - previousHeading)
            if headingDifference > 45 && currentSpeed > turnSpeedLimit {
                recordInfraction("Excessive speed on turn: \(Int(currentSpeed)) km/h")
            }
        }
        previousHeading = latestLocation.course
        
        // Check for infractions
        // Waypoint logic
        if currentWaypointIndex < route.count {
            let waypoint = route[currentWaypointIndex]
            let userLocation = CLLocation(latitude: latestLocation.coordinate.latitude, longitude: latestLocation.coordinate.longitude)
            let waypointLocation = CLLocation(latitude: waypoint.latitude, longitude: waypoint.longitude)
            let distanceToWaypoint = userLocation.distance(from: waypointLocation)

            // Failure to stop at a designated waypoint
            if waypoint.requiresStop && distanceToWaypoint < 20 && currentSpeed > 0.5 {
                recordInfraction("Failure to stop at waypoint \(currentWaypointIndex + 1)")
            }

            // Move to the next waypoint if close enough
            if distanceToWaypoint < 20 {
                currentWaypointIndex += 1
            }
        }
        
        
        
        print(#function, "Current location: \(latestLocation), Speed: \(currentSpeed) m/s")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function, "Unable to receive location changes due to error: \(error)")
    }
    
    private func recordInfraction(_ description: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .medium)
        infractions.append("\(timestamp): \(description)")
    }
}

