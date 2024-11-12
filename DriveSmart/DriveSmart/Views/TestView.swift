//Created by: Melissa Munoz

import SwiftUI
import CoreLocation

struct TestView: View {
    
    // UI States
    @State private var showRouteSheet = false
    @State private var showResultsView = false
    @State private var showProximityAlert = false
    @State private var showRouteAlert = false
    
    // Logic States
    @State private var isStarted = false
    
    // For Instructions
    @State private var instructionIndex = 0
    
    // Initializers
    @StateObject private var locationManager = LocationManager()
    @StateObject private var speechRecognizerManager = SpeechRecognizerManager()
    @StateObject private var instructionManager = InstructionManager(speechManager: SpeechManager())
    @StateObject private var proximityManager: ProximityManager
    
    init() {
        let stopSigns = [
            CLLocation(latitude: 43.41172587297663, longitude: -79.73182668583425),
            CLLocation(latitude: 43.41252410618511, longitude: -79.73163606984338)
        ]
        let trafficLights = [
            CLLocation(latitude: 43.42181176989304, longitude: -79.72189370556212),
            CLLocation(latitude: 43.42893241854303, longitude: -79.73115138899801)
        ]
        _proximityManager = StateObject(wrappedValue: ProximityManager(stopSigns: stopSigns, trafficLights: trafficLights))
    }

    // Locations
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
                .id("MapView") // Static view
            
            VStack {
                Spacer()
                Button(action: {
                    
                    // Must be within the starting location
                    if proximityManager.isStartLocationProximity {
                        isStarted = true
                        showRouteSheet = true
                        locationManager.startUpdatingLocation()
                    } else {
                        showProximityAlert = true
                    }
                    
                }) {
                    Text("Start Route")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .toolbarBackground(Color("UIBlack"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            if !isStarted {
                locationManager.startUpdatingLocation()
                speechRecognizerManager.requestAuthorization()
            }
        }
        .onDisappear {
            locationManager.stopUpdatingLocation()
        }
        .onReceive(locationManager.$currentLocation) { newLocation in
            // ALWAYS check if user is near the start proximity when isStarted is FALSE
            proximityManager.checkStartProximity(to: newLocation, locations: oakvilleLocation, instructionIndex: instructionIndex)
            
            // Only check proximities if the user STARTS the application
            if isStarted {
                proximityManager.checkStopProximity(to: newLocation)
                proximityManager.checkRouteProximity(to: newLocation, locations: oakvilleLocation)
                proximityManager.checkInstructionProximity(to: newLocation, locations: oakvilleLocation, instructionManager: instructionManager)
            }
        }
        .alert(isPresented: $showProximityAlert) {  // Alert for proximity
            Alert(
                title: Text("Not Near Route"),
                message: Text("Please approach the starting location."),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(isPresented: $showRouteSheet) {
            RouteSheetView(currentInstruction: $instructionManager.currentInstruction, recognizedText: $speechRecognizerManager.recognizedText, showRouteAlert: $showRouteAlert, isNotInRoute: $proximityManager.isNotInRoute, onCancel: {
                locationManager.stopUpdatingLocation()
                speechRecognizerManager.stopRecording()
                showRouteSheet = false
                isStarted = false
                showResultsView = true // Trigger navigation to ResultsView
            })
            .presentationDetents([.medium, .fraction(0.5)])
            .interactiveDismissDisabled()
        }
        .background(
            NavigationLink(destination: ResultsView(checklistItems: speechRecognizerManager.checklist), isActive: $showResultsView) {
                EmptyView()
            }
        )
    }
}



//SHEET WILL APPEAR WHEN USER CLICKS THE BUTTON, IT CANNOT BE DISMISSED UNTIL USER HAS CLICKED CANCEL ROUTE
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
                Text("End Route")
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


