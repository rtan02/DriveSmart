//Created by: Melissa Munoz

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

    
    init(stopSigns: [CLLocation], trafficLights: [CLLocation], tests: [Location]) {
            self.stopSigns = stopSigns
            self.trafficLights = trafficLights
        self.tests = tests
//            self.instructionManager = instructionManager
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
//                instructionManager.updateInstruction(with: location.instruction)
//            }
//        }
//        
//        // Update the instruction only when the user approaches a new location (within 20 meters)
//        if closestDistance < 20 && closestLocationName != instructionManager.currentInstruction {
//            if !spokenInstructionMarkers.contains(closestLocationName) {
//                spokenInstructionMarkers.insert(closestLocationName) // Add to the spoken set
//                instructionManager.updateInstruction(with: closestLocationName)
//                print("Adding \(closestLocationName) to spoken instruction set.")
//            }
//        }
//    }

//    //MARK: Check Test Proximity
//    func checkProximityToTestLocations(to currentLocation: CLLocation?, instructionManager: InstructionManager) {
//        guard let currentLocation = currentLocation else { return }
//        
//        var closestDistance = Double.greatestFiniteMagnitude
//        var closestInstruction = ""
//        
//        // Check test locations
//        for location in tests {
//            let targetLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
//            let distance = currentLocation.distance(from: targetLocation)
//            if distance < closestDistance {
//                closestDistance = distance
//                closestInstruction = location.instruction
//            }
//        }
//        
//        // If the closest test location is within range (e.g., 20 meters) AND is not the same as the current instruction, update the instruction
//        if closestDistance < 20 && closestInstruction != instructionManager.currentInstruction {
//            if !spokenTestMarkers.contains(closestInstruction) {
//                spokenTestMarkers.insert(closestInstruction) // Add to the spoken set
//                print("Adding \(closestInstruction) to spoken test set.")
//            }
//        }
//    }
    //MARK: Check Instruction Proximity
    func checkInstructionProximity(to currentLocation: CLLocation?, locations: [Location], instructionManager: InstructionManager) {
        
        //Ensures it's not non-nil
        guard let currentLocation = currentLocation else { return }
        
        //commonly used in algorithms like finding the smallest distance or value in a dataset
        var closestDistance = Double.greatestFiniteMagnitude
        var closestLocationInstruction: String = ""
        
        for location in locations {
            
            //The target location
            let targetLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            
            //Calculate the distance from current location to target location
            let distance = currentLocation.distance(from: targetLocation)
            
            print("Checking location \(location.instruction) at distance: \(distance) meters")
            
            //If the distance is less than the closest distance
            if distance < closestDistance {
                //Save it in the variable to note that its the closest one
                closestDistance = distance
                //And use it's instruction
                closestLocationInstruction = location.instruction
            }
        }
        
        // Update the instruction only when the user approaches a new location (within 20 meters)
        if closestDistance < 20 && closestLocationInstruction != instructionManager.currentInstruction {
            instructionManager.updateInstruction(with: closestLocationInstruction)
            print("User is close enough to the instruction: \(closestLocationInstruction), instruction updated.")
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
                if !spokenInstructionMarkers.contains(closestInstruction){
                    instructionManager.updateInstruction(with: closestInstruction)
                    print("Adding \(closestInstruction) to spoken instruction set.")
                    
                }
            }
        }
    
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
                    spokenStopSigns.insert(stopSign)
                    instructionManager.updateInstruction(with: "Approaching Stop Sign" )
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
                    spokenTrafficLights.insert(trafficLight)
                    instructionManager.updateInstruction(with: "Approaching Traffic Light" )
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
    
    func resetSpokenSets() {
        spokenStopSigns.removeAll()
        spokenTrafficLights.removeAll()
        spokenInstructionMarkers.removeAll()
        spokenTestMarkers.removeAll()
        print("Spoken sets have been reset.")
    }

}
