import SwiftUI
import CoreLocation
import CoreMotion

struct ContentView: View {
    @ObservedObject private var locationManager = LocationManager()
    @ObservedObject private var motionManager = MotionManager()
    @State private var isRouteComplete = false
    
    var body: some View {
        VStack {
            if !isRouteComplete {
                VStack {
                    Text("Driving Practice")
                        .font(.largeTitle)
                        .padding()
                    
                    Text("Speed: \(String(format: "%.2f", locationManager.speed)) km/h")
                        .font(.headline)
                        .padding()
                    
                    if motionManager.isHardBraking {
                        Text("Hard Braking Detected!")
                            .foregroundColor(.red)
                            .font(.headline)
                            .padding()
                    }
                    
                    if motionManager.isHardAcceleration {
                        Text("Hard Acceleration Detected!")
                            .foregroundColor(.green)
                            .font(.headline)
                            .padding()
                    }
                    
                    if motionManager.isHardTurning {
                        Text("Hard Turning Detected!")
                            .foregroundColor(.orange)
                            .font(.headline)
                            .padding()
                    }
                    
                    Button("Complete Route") {
                        isRouteComplete = true
                    }
                    .padding()
                }
            } else {
                SummaryView(infractions: locationManager.infractions)
            }
        }
        .onAppear {
            motionManager.startMotionTracking()
        }
    }
}

struct SummaryView: View {
    let infractions: [String]
    
    var body: some View {
        VStack {
            Text("Summary of Infractions")
                .font(.largeTitle)
                .padding()
            
            if infractions.isEmpty {
                Text("No infractions recorded. Great job!")
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding()
            } else {
                List(infractions, id: \.self) { infraction in
                    Text(infraction)
                }
            }
        }
        .padding()
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    @Published var speed: Double = 0.0
    @Published var infractions: [String] = []
    private var currentWaypointIndex = 0
    
    private let route: [RouteSegment] = [
        RouteSegment(latitude: 43.6768, longitude: -79.8218, speedLimit: 30, requiresStop: true),
        RouteSegment(latitude: 43.6774, longitude: -79.8228, speedLimit: 30, requiresStop: false),
        RouteSegment(latitude: 43.6780, longitude: -79.8241, speedLimit: 30, requiresStop: false),
        RouteSegment(latitude: 43.6786, longitude: -79.8257, speedLimit: 30, requiresStop: true),
        RouteSegment(latitude: 43.6791, longitude: -79.8273, speedLimit: 30, requiresStop: false),
        RouteSegment(latitude: 46.6797, longitude: -79.8293, speedLimit: 30, requiresStop: true),
        // Add more waypoints as needed
    ]
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let currentSpeed = location.speed >= 0 ? location.speed * 3.6 : 0.0 // Convert to km/h
            self.speed = currentSpeed
            
            // Check for infractions
            if currentWaypointIndex < route.count {
                let waypoint = route[currentWaypointIndex]
                let userLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                let waypointLocation = CLLocation(latitude: waypoint.latitude, longitude: waypoint.longitude)
                let distanceToWaypoint = userLocation.distance(from: waypointLocation)
                
                // Speeding infraction
                if currentSpeed > waypoint.speedLimit {
                    recordInfraction("Speeding: \(currentSpeed) km/h in a \(waypoint.speedLimit) km/h zone")
                }
                
                // Route deviation infraction
                if distanceToWaypoint > 500 { // 100 meters as acceptable deviation
                    recordInfraction("Route Deviation: Off track by \(Int(distanceToWaypoint)) meters")
                }
                
                // Failure to stop at designated waypoint
                if waypoint.requiresStop && distanceToWaypoint < 20 && currentSpeed > 0.5 {
                    recordInfraction("Failure to stop at waypoint \(currentWaypointIndex + 1)")
                }
                
                // Move to the next waypoint if close
                if distanceToWaypoint < 20 {
                    currentWaypointIndex += 1
                }
            }
        }
    }
    
    private func recordInfraction(_ description: String) {
        let timestamp = Date()
        infractions.append("\(timestamp): \(description)")
    }
}

class MotionManager: ObservableObject {
    private var motion = CMMotionManager()
    @Published var isHardBraking = false
    @Published var isHardAcceleration = false
    @Published var isHardTurning = false
    
    private let hardBrakeThreshold: Double = -1.5 // m/s^2
    private let hardAccelerationThreshold: Double = 1.5 // m/s^2
    private let hardTurnThreshold: Double = 4.0 // radians/second
    
    func startMotionTracking() {
        if motion.isAccelerometerAvailable && motion.isGyroAvailable {
            motion.accelerometerUpdateInterval = 0.1 // Update every 0.1 seconds
            motion.gyroUpdateInterval = 0.1
            
            // Accelerometer Updates
            motion.startAccelerometerUpdates(to: OperationQueue.main) { [weak self] (data, error) in
                if let accelerometerData = data {
                    let accelerationZ = accelerometerData.acceleration.z
                    
                    // Detect hard braking (significant negative acceleration)
                    self?.isHardBraking = accelerationZ < self?.hardBrakeThreshold ?? -1.5
                    
                    // Detect hard acceleration (significant positive acceleration)
                    self?.isHardAcceleration = accelerationZ > self?.hardAccelerationThreshold ?? 1.5
                }
            }
            
            // Gyroscope Updates
            motion.startGyroUpdates(to: OperationQueue.main) { [weak self] (data, error) in
                if let gyroData = data {
                    let rotationRateY = gyroData.rotationRate.y
                    
                    // Detect hard turning (high angular velocity)
                    self?.isHardTurning = abs(rotationRateY) > self?.hardTurnThreshold ?? 4.0
                }
            }
        }
    }
}

struct RouteSegment {
    let latitude: Double
    let longitude: Double
    let speedLimit: Double // in km/h
    let requiresStop: Bool
}

@main
struct DrivingPracticeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
