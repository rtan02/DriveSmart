import SwiftUI
import CoreLocation

struct TestView: View {
    
    //UI States
    @State private var showRouteSheet = false
    @State private var showResultsView = false
    @State private var showProximityAlert = false
    @State private var showRouteAlert = false
    
    
    //Logic States
    @State private var isStarted = false
    @State private var isStartLocationProximity = false
    @State private var isNotInRoute = false
    @State private var isNearStopSign = false
    @State private var isNearTrafficLight = false
    
    //For Instructions
    @State private var instructionIndex = 0
    @State private var currentInstruction = "Proceed to the start location."
    
    // Initializers
    @StateObject private var locationManager = LocationManager()
    @StateObject private var speechRecognizerManager = SpeechRecognizerManager()
    private let speechService = SpeechService()
    
    //MARK: These need to be loaded from the Cloud
    //Traffic And Stop Signs
    let stopSigns = [
        CLLocation(latitude: 43.41172587297663, longitude: -79.73182668583425),
        CLLocation(latitude: 43.41252410618511, longitude: -79.73163606984338)
    ]
    
    let trafficLights = [
        CLLocation(latitude: 43.42181176989304, longitude: -79.72189370556212),
        CLLocation(latitude: 43.42893241854303, longitude: -79.73115138899801)
    ]
    
    //Locations
    private let oakvilleLocation = [
        Location(latitude: 43.41172587297663, longitude: -79.73182668583425, name: "Test Center"),
        Location(latitude: 43.41252410618511, longitude: -79.73163606984338, name: "Turn Left"),
        Location(latitude: 43.42181176989304, longitude: -79.72189370556212, name: "Third Line"),
        Location(latitude: 43.42893241854303, longitude: -79.73115138899801, name: "Kings College Dr"),
        Location(latitude: 43.430518018291274, longitude: -79.73560051162885, name: "Grainer Court"),
        Location(latitude: 43.431278749509225, longitude: -79.73653623982118, name: "Blacksmith Ln"),
        Location(latitude: 43.42978292062415, longitude: -79.73688934480235, name: "King's College Dr"),
        Location(latitude: 43.42884766429311, longitude: -79.73127332105396, name: "Third Line"),
        Location(latitude: 43.41172587297663, longitude: -79.73182668583425, name: "Test Center")
    ]
    
    var body: some View {
        
        
        let coordinates = oakvilleLocation.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        
        ZStack {
            MapView(coordinates: coordinates, userLocation: locationManager.currentLocation?.coordinate)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                Button(action: {
                    
                    //Must be within the starting location
                    if isStartLocationProximity{
                        isStarted = true
                        showRouteSheet = true
                        locationManager.startUpdatingLocation()
                        updateInstruction()
                    }else{
                        showProximityAlert = true
                    }//If-Else Block
                    
                    
                }){
                    Text("Start Route")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }//VStack
        }//ZStack
        .toolbarBackground(Color("UIBlack"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            if !isStarted {
                locationManager.startUpdatingLocation()
                speechRecognizerManager.requestAuthorization()
            }
        }//OnAppear
        .onDisappear {
            locationManager.stopUpdatingLocation()
        }//OnDisappear
        .onReceive(locationManager.$currentLocation) { newLocation in
            checkProximity(to: newLocation, locations: oakvilleLocation)
            checkStopProximity(to: newLocation, stopSigns: stopSigns, trafficLights: trafficLights)
            checkRouteProximity(to: newLocation, locations: oakvilleLocation)
        }//OnReceive
        .alert(isPresented: $showProximityAlert) {  // Alert for proximity
            Alert(
                title: Text("Not Near Route"),
                message: Text("Please approach the starting location."),
                dismissButton: .default(Text("OK"))
            )
        }//Proximity Alert
        .sheet(isPresented: $showRouteSheet) {
            RouteSheetView(currentInstruction: $currentInstruction, recognizedText: $speechRecognizerManager.recognizedText, showRouteAlert: $showRouteAlert, isNotInRoute: $isNotInRoute, onCancel: {
                //When you stop the route and dismiss the sheet, reset everything
                locationManager.stopUpdatingLocation()
                speechRecognizerManager.stopRecording()
                showRouteSheet = false
                isStarted = false
                currentInstruction = "Proceed to the start location."
                showResultsView = true // Trigger navigation to ResultsView
                
            })
            .presentationDetents([.medium, .fraction(0.5)])
        }//Sheet
        .background(
            //This will only be called if ShowResultsView == True
            //Meaning, this is the END of the navigation
            NavigationLink(destination: ResultsView(checklistItems: speechRecognizerManager.checklist), isActive: $showResultsView) {
                EmptyView()
            }
        )
    }
    
    //ThisWillStartListening and GivingInstructions
    private func updateInstruction() {
        do{
            try speechRecognizerManager.startRecording()
        }catch{
            print("Error starting recording: \(error)")
        }
    }//UpdateInstruction
    
    //MARK: Check proximity from currentLocation
    private func checkProximity(to currentLocation: CLLocation?, locations: [Location]) {
        
        guard let currentLocation = currentLocation else { return }
        
        let startingLocation = CLLocation(latitude: locations.first?.latitude ?? 0, longitude: locations.first?.longitude ?? 0)
        
        let targetLocation = CLLocation(latitude: locations[instructionIndex].latitude, longitude: locations[instructionIndex].longitude)
        
        let startDistance = currentLocation.distance(from: startingLocation)
        let targetDistance = currentLocation.distance(from: targetLocation)
        
        print("\n Distance to start: \(startDistance) meters.\n")
        print("\n Distance to next target: \(targetDistance) meters. \n")
        
        //The <1000 is indicative of meters
        //MARK: This is to find the distance from the startingLocation to currentLocation AKA If they're on the route
        if currentLocation.distance(from: startingLocation) < 100{
            print("\n Current Location within 1000, setting to true \n")
            isStartLocationProximity = true
        }else{
            print("\n Current Location not within 1000, setting to false \n")
            isStartLocationProximity = false
        }//if-else
    }//CheckProximity Function
    
    //MARK: Check STOP proximity from currentLocation
    private func checkStopProximity(to currentLocation: CLLocation?, stopSigns: [CLLocation], trafficLights: [CLLocation]){
        
        isNearTrafficLight = false
        isNearStopSign = false
        
        
        guard let currentLocation = currentLocation else { return }
        
        //        print("\n Current Location From Stop/Traffic Light: \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude) \n")
        
        
        for stopSign in stopSigns {
            
            if currentLocation.distance(from: stopSign) < 20 {
                isNearStopSign = true
                let distanceToStopSign = currentLocation.distance(from: stopSign)
                
                print("\n Distance to Stop Sign: \(distanceToStopSign) meters \n")
                print("\n User is near stop sign \n")
                //MARK: Voice activation must be done to notify the user they are approaching a stop sign
                
                break
            }
        }
        
        // Check proximity to traffic lights
        for trafficLight in trafficLights {
            if currentLocation.distance(from: trafficLight) < 20 {
                isNearTrafficLight = true
                let distanceToTrafficLight = currentLocation.distance(from: trafficLight)
                
                print("\n Distance to Traffic Light: \(distanceToTrafficLight) meters \n")
                print("\n User is near traffic light \n")
                //MARK: Voice activation must be done to notify the user they are approaching a stop sign
                
                break
            }
        }
    }//CheckStopProximity Function
    
    private func checkRouteProximity(to currentLocation: CLLocation?, locations: [Location]) {
        
        guard let currentLocation = currentLocation else { return }
        
        isNotInRoute = false
        
        //essentially a huge number that’s guaranteed to be larger than any typical distance in this context
        var closestDistance = Double.greatestFiniteMagnitude
        
        // This is finding the closest point from the user location
        for location in locations {
            let routePoint = CLLocation(latitude: location.latitude, longitude: location.longitude)
            let distance = currentLocation.distance(from: routePoint)
            
            // Update closestDistance if this point is closer
            if distance < closestDistance {
                closestDistance = distance
            }
        }
        
        // If that user is further than 50 m from that route, than IsInRoute will be false, if they are within the route, they will continue
        if closestDistance > 100 {  // Adjust threshold as needed
            //MARK: Fix the logic behind this, there needs to be a counter for how long they will remain out of route to notify the user
//            isNotInRoute = true
//            showRouteAlert = true
            print("You are off the route. Please return to the designated path.")
        }
    }//CheckRouteProximity
    
    
}//TESTVIEW

//SHEET WILL APPEAR WHEN USER CLICKS THE BUTTON
struct RouteSheetView: View {
    @Binding var currentInstruction: String
    @Binding var recognizedText: String
    @Binding var showRouteAlert: Bool
    @Binding var isNotInRoute: Bool
    var onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Test Instructions")
                .font(.title)
                .fontWeight(.bold)
            
            Text(currentInstruction)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
            
            Text(recognizedText)
                .font(.subheadline)
                .lineLimit(2)
                .padding()
                .cornerRadius(10)
            
            Spacer()
            
            Button(action: {
                onCancel()
            }) {
                Text("Cancel Route")
                    .font(.headline)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
        .alert(isPresented: $showRouteAlert) {
            Alert(
                title: Text("Off Route"),
                message: Text("You are off the designated route. Please return to the path."),
                dismissButton: .default(Text("OK")) {
                    // Dismiss button is temporarily inactive until user returns to the route
                    if isNotInRoute {
                        showRouteAlert = true
                    }
                }
            )
        }//RouteAlert
    }
}


