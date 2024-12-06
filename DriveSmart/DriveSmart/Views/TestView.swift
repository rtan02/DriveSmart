
import SwiftUI
import CoreLocation

struct TestView: View {
    
    // UI States
    @State private var isShowingRouteSheet = false
    @State private var isShowingResultsView = false
    @State private var isShowingProximityAlert = false
    @State private var isShowingRouteAlert = false
    
    // Logic States
    @State private var isStarted = false
    @State private var isDataLoaded = false
    
    
    // For Firebase
    @StateObject private var firebaseManager = FirebaseManager()
    @State private var locationData: LocationData? = nil
    var locationName: String // To determine what location they want
    
    // Initializers
    @StateObject private var locationManager = LocationManager()
    @StateObject private var speechRecognizerManager = SpeechRecognizerManager()
    @StateObject private var instructionManager = InstructionManager(speechManager: SpeechManager())
    @StateObject private var proximityManager: ProximityManager
    
    init(locationName: String) {
        self.locationName = locationName
        _proximityManager = StateObject(wrappedValue: ProximityManager(stopSigns: [], trafficLights: [])) // Default empty
    }
    
    var body: some View {
        
        var coordinates: [CLLocationCoordinate2D] {
            let coords = locationData?.locations.map {
                CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
            } ?? []
            return coords
        }
        
        
        ZStack {
            if isDataLoaded {
                MapView(coordinates: coordinates, userLocation: locationManager.currentLocation?.coordinate, firebaseManager: firebaseManager)
                    .edgesIgnoringSafeArea(.all)
                    .id("MapView") // Static view
            }else{
                Text("Loading Data...")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            VStack {
                Spacer()
                Button(action: {
                    print("isStartLocationProximity: \(proximityManager.isWithinStartLocation)")
                    print("isStarted: \(isStarted)")
                    // Must be within the starting location
                    if proximityManager.isWithinStartLocation {
                        isStarted = true
                        isShowingRouteSheet = true
                        locationManager.startUpdatingLocation()
                    } else {
                        isShowingProximityAlert = true
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
            // Fetch location data from Firebase
            firebaseManager.fetchLocationData(for: locationName) { fetchedData in
                if let data = fetchedData {
                    locationData = data
                    
                    // Pass the stop signs and traffic lights to proximity manager
                    proximityManager.stopSigns = data.stopSigns
                    proximityManager.trafficLights = data.trafficLights
                    
                    proximityManager.tests = data.tests
                    
                    isDataLoaded = true
                }
                
                if !isStarted {
                    
                    locationManager.startUpdatingLocation()
                    speechRecognizerManager.requestAuthorization()
                }
            }
        }
        .onDisappear {
            locationManager.stopUpdatingLocation()
        }
        .onReceive(locationManager.$currentLocation) { newLocation in
            
            print("Received new location: \(newLocation?.coordinate.latitude ?? 0), \(newLocation?.coordinate.longitude ?? 0)")  // Add this line

            guard let locationData = locationData else { return }
             
            // Check proximity to start location
            proximityManager.checkStartProximity(to: newLocation, locations: locationData.locations)
            
            if isStarted {
                
                proximityManager.checkProximityToTestLocations(to: newLocation, instructionManager: instructionManager)
                // Only check proximities if the route is started
                proximityManager.checkStopProximity(to: newLocation, instructionManager: instructionManager)
                proximityManager.checkRouteProximity(to: newLocation, locations: locationData.locations)
                proximityManager.checkInstructionProximity(to: newLocation, locations: locationData.locations, instructionManager: instructionManager)
//                proximityManager.checkInstructionProximity(to: newLocation, locations: locationData.locations, instructionManager: instructionManager)
            }
        }
        .alert(isPresented: $isShowingProximityAlert) {  // Alert for proximity
            Alert(
                title: Text("Not Near Route"),
                message: Text("Please approach the starting location."),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(isPresented: $isShowingRouteSheet) {
            RouteSheetView(currentInstruction: $instructionManager.currentInstruction, recognizedText: $speechRecognizerManager.recognizedText, showRouteAlert: $isShowingRouteAlert, isNotInRoute: $proximityManager.isNotInRoute, onCancel: {
                locationManager.stopUpdatingLocation()
                speechRecognizerManager.stopRecording()
                isShowingRouteSheet = false
                isStarted = false
                isShowingResultsView = true // Trigger navigation to ResultsView
            })
            .presentationDetents([.medium, .fraction(0.5)])
            .interactiveDismissDisabled()
        }
        .background(
            NavigationLink(destination: ResultsView(checklistItems: speechRecognizerManager.checklist), isActive: $isShowingResultsView) {
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


