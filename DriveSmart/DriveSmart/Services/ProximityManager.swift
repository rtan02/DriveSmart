//Created by: Melissa Munoz

import Foundation
import CoreLocation

class ProximityManager: ObservableObject {
    @Published var isStartLocationProximity = false
    @Published var isNotInRoute = false
    @Published var isNearStopSign = false
    @Published var isNearTrafficLight = false
    
    var stopSigns: [CLLocation]
    var trafficLights: [CLLocation]
    
    init(stopSigns: [CLLocation], trafficLights: [CLLocation]) {
        self.stopSigns = stopSigns
        self.trafficLights = trafficLights
    }
    
    //MARK: Check proximity from currentLocation
    func checkStartProximity(to currentLocation: CLLocation?, locations: [Location], instructionIndex: Int) {
        
        guard let currentLocation = currentLocation else { return }
        
        let startingLocation = CLLocation(latitude: locations.first?.latitude ?? 0, longitude: locations.first?.longitude ?? 0)
        
        print("Start location: \(locations.first?.latitude ?? 0), \(locations.first?.longitude ?? 0)\n")
        print("User's current location: \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)\n")

        
        if currentLocation.distance(from: startingLocation) < 1000 {
            self.isStartLocationProximity = true
            print("User is within start location proximity")
        } else {
            self.isStartLocationProximity = false
            print("User is NOT within start location proximity")
        }
    }
    
    //MARK: Check Instruction Proximity
    func checkInstructionProximity(to currentLocation: CLLocation?, locations: [Location], instructionManager: InstructionManager) {
        guard let currentLocation = currentLocation else { return }
        
        var closestIndex = instructionManager.instructionIndex
        var closestDistance = Double.greatestFiniteMagnitude
        
        for (index, location) in locations.enumerated() {
            let targetLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            let distance = currentLocation.distance(from: targetLocation)
            
            print("Checking instruction \(index) at distance: \(distance) meters")
            
            if distance < closestDistance {
                closestDistance = distance
                closestIndex = index
            }
        }
        
        if closestIndex != instructionManager.instructionIndex {
            instructionManager.instructionIndex = closestIndex
            instructionManager.currentInstruction = instructionManager.instructions[closestIndex]
            print("Moved to next instruction: \(instructionManager.currentInstruction)")
        }
        
        if closestDistance < 20 {
            instructionManager.updateInstruction()  // Move to next instruction
            print("User is close enough to the instruction, moving to the next one.")
        }
    }
    
    //MARK: Check Stop and Traffic Light Proximity
    func checkStopProximity(to currentLocation: CLLocation?) {
        guard let currentLocation = currentLocation else { return }
        
        self.isNearTrafficLight = false
        self.isNearStopSign = false
        
        for stopSign in stopSigns {
            let distance = currentLocation.distance(from: stopSign)
            print("Checking stop sign at distance: \(distance) meters")
            if distance < 20 {
                self.isNearStopSign = true
                print("User is near a stop sign")
                break
            }
        }
        
        for trafficLight in trafficLights {
            let distance = currentLocation.distance(from: trafficLight)
            print("Checking traffic light at distance: \(distance) meters")
            if distance < 20 {
                self.isNearTrafficLight = true
                print("User is near a traffic light")
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
