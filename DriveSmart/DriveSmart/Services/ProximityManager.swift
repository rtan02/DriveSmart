
import Foundation
import CoreLocation

class ProximityManager: ObservableObject {
    @Published var isWithinStartLocation = false
    @Published var isNotInRoute = false
    @Published var isNearStopSign = false
    @Published var isNearTrafficLight = false
    
    var instructionManager: InstructionManager?
//    var instructions: [String] = []

    var stopSigns: [CLLocation]
    var trafficLights: [CLLocation]
    var tests: [Location] = []

    
    init(stopSigns: [CLLocation], trafficLights: [CLLocation]) {
        self.stopSigns = stopSigns
        self.trafficLights = trafficLights
    }
    
    //During testing, there was repetition in the voice commands
    //App needs to track which ones have already been spoken
    private var spokenStopSigns: Set<CLLocation> = []
    private var spokenTrafficLights: Set<CLLocation> = []
    private var spokenInstructionMarkers: Set<String> = []
    private var spokenTestMarkers: Set<String> = []

    
    
    //MARK: Check proximity from currentLocation
    func checkStartProximity(to currentLocation: CLLocation?, locations: [Location]) {
        
        guard let currentLocation = currentLocation else { return }
        
        let startingLocation = CLLocation(latitude: locations.first?.latitude ?? 0, longitude: locations.first?.longitude ?? 0)
        
        print("Start location: \(locations.first?.latitude ?? 0), \(locations.first?.longitude ?? 0)\n")
        print("User's current location: \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)\n")

        
        if currentLocation.distance(from: startingLocation) < 1000 {
            self.isWithinStartLocation = true
            print("User is within start location proximity")
        } else {
            self.isWithinStartLocation = false
            print("User is NOT within start location proximity")
        }
    }
    
    //MARK: Check Instruction Proximity
    func checkInstructionProximity(to currentLocation: CLLocation?, locations: [Location], instructionManager: InstructionManager) {
        guard let currentLocation = currentLocation else { return }
        
        var closestDistance = Double.greatestFiniteMagnitude
        var closestLocationName: String = ""
        
        for location in locations {
            let targetLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            let distance = currentLocation.distance(from: targetLocation)
            
            print("Checking location \(location.instruction) at distance: \(distance) meters")
            
            if distance < closestDistance {
                closestDistance = distance
                closestLocationName = location.instruction // Set the closest location's name
            }
        }
        
        // Update the instruction only when the user approaches a new location (within 20 meters)
        if closestDistance < 20 && closestLocationName != instructionManager.currentInstruction {
            if !spokenInstructionMarkers.contains(closestLocationName) {
                instructionManager.updateInstruction(with: closestLocationName)
                print("Adding \(closestLocationName) to spoken instruction set.")
                spokenInstructionMarkers.insert(closestLocationName) // Add to the spoken set
            }
        }
    }

    //MARK: Check Test Proximity
    func checkProximityToTestLocations(to currentLocation: CLLocation?, instructionManager: InstructionManager) {
        guard let currentLocation = currentLocation else { return }
        
        var closestDistance = Double.greatestFiniteMagnitude
        var closestInstruction = ""
        
        // Check test locations
        for location in tests {
            let targetLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            let distance = currentLocation.distance(from: targetLocation)
            if distance < closestDistance {
                closestDistance = distance
                closestInstruction = location.instruction
            }
        }
        
        // If the closest test location is within range (e.g., 20 meters) AND is not the same as the current instruction, update the instruction
        if closestDistance < 20 && closestInstruction != instructionManager.currentInstruction {
            if !spokenTestMarkers.contains(closestInstruction) {
                instructionManager.updateInstruction(with: closestInstruction)
                print("Adding \(closestInstruction) to spoken test set.")
                spokenTestMarkers.insert(closestInstruction) // Add to the spoken set
            }
        }
    }
//    //MARK: Check Instruction Proximity
//    func checkInstructionProximity(to currentLocation: CLLocation?, locations: [Location], instructionManager: InstructionManager) {
//        guard let currentLocation = currentLocation else { return }
//        
//        var closestDistance = Double.greatestFiniteMagnitude
//        var closestLocationName: String = ""
//        
//        for location in locations {
//            let targetLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
//            let distance = currentLocation.distance(from: targetLocation)
//            
//            print("Checking location \(location.instruction) at distance: \(distance) meters")
//            
//            if distance < closestDistance {
//                closestDistance = distance
//                closestLocationName = location.instruction // Set the closest location's name
//            }
//        }
//        
//        // Update the instruction only when the user approaches a new location (within 20 meters)
//        if closestDistance < 20 && closestLocationName != instructionManager.currentInstruction {
//            instructionManager.updateInstruction(with: closestLocationName)
//            print("User is close enough to the instruction: \(closestLocationName), instruction updated.")
//        }
//    }
//    
//    //MARK: Check Test Proximity
//        func checkProximityToTestLocations(to currentLocation: CLLocation?, instructionManager: InstructionManager) {
//            guard let currentLocation = currentLocation else { return }
//            
//            var closestDistance = Double.greatestFiniteMagnitude
//            var closestInstruction = ""
//            
//            // Check test locations
//            for location in tests {
//                let targetLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
//                let distance = currentLocation.distance(from: targetLocation)
//                if distance < closestDistance {
//                    closestDistance = distance
//                    closestInstruction = location.instruction
//                }
//            }
//            
//            // If the closest test location is within range (e.g., 20 meters) AND is not the same as the current instruction, update the instruction
//            if closestDistance < 20 && closestInstruction != instructionManager.currentInstruction {
//                if !spokenInstructionMarkers.contains(closestInstruction){
//                    instructionManager.updateInstruction(with: closestInstruction)
//                    print("Adding \(closestInstruction) to spoken instruction set.")
//                    
//                }
//            }
//        }
//    
    //MARK: Check Stop and Traffic Light Proximity
    func checkStopProximity(to currentLocation: CLLocation?, instructionManager: InstructionManager) {
        guard let currentLocation = currentLocation else { return }
        
        self.isNearTrafficLight = false
        self.isNearStopSign = false
        
        for stopSign in stopSigns {
            let distance = currentLocation.distance(from: stopSign)
            print("Checking stop sign at distance: \(distance) meters")
            if distance < 20{
                self.isNearStopSign = true
                print("User is near a stop sign")
                if !spokenStopSigns.contains(stopSign){
                    print("Adding \(stopSign) to spoken stop sign.")
                    instructionManager.updateInstruction(with: "Approaching Stop Sign" )
                    spokenStopSigns.insert(stopSign)
                }
                break
            }
        }
        
        for trafficLight in trafficLights {
            let distance = currentLocation.distance(from: trafficLight)
            print("Checking traffic light at distance: \(distance) meters")
            if distance < 20 {
                self.isNearTrafficLight = true
                print("User is near a traffic light")
                if !spokenTrafficLights.contains(trafficLight){
                    instructionManager.updateInstruction(with: "Approaching Traffic Light" )
                    spokenTrafficLights.insert(trafficLight)
                    print("Adding \(trafficLight) to spoken traffic light set list.")
                }
                break
            }
        }
    }
    
    //MARK: Check Route Proximity
    func checkRouteProximity(to currentLocation: CLLocation?, locations: [Location]) {
        guard let currentLocation = currentLocation else { return }
        
        var closestDistance = Double.greatestFiniteMagnitude
        
        for location in locations {
            let routePoint = CLLocation(latitude: location.latitude, longitude: location.longitude)
            let distance = currentLocation.distance(from: routePoint)
            
            print("Checking route point at distance: \(distance) meters")
            
            if distance < closestDistance {
                closestDistance = distance
            }
        }
        
        if closestDistance > 100 {
            self.isNotInRoute = true
            print("User is too far from the route")
        } else {
            self.isNotInRoute = false
            print("User is within route proximity")
        }
    }
}
