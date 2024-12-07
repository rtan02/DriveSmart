
import SwiftUI
import CoreLocation

struct TestView: View {
    
    //MARK: STATES
    
    //**UI States
    @State private var isShowingResultsView = false
    @State private var isShowingProximityAlert = false
    
//    @State private var isShowingRouteAlert = false
//    //To show if user is within starting location
    
    @State private var isRouteButtonToggled = false
    
    //**Logic States
    @State private var isStarted = false //Controls what starts the test
    @State private var isDataLoaded = false //Checks if Data from firebase is loaded

    
    //**Services
    @StateObject private var firebaseManager = FirebaseManager()
    @State private var locationData: LocationData? = nil
    var locationName: String // To determine what location they want, passed from results page
    
    //**Initializers
    @StateObject private var locationManager = LocationManager()
    @StateObject private var speechRecognizerManager = SpeechRecognizerManager()
    @StateObject private var instructionManager = InstructionManager(speechManager: SpeechManager())
    @StateObject private var proximityManager: ProximityManager
    
    
    //MARK: Speed
    @State private var infractions: [Int] = [] // List of over-speed values

    func handleSpeedingInfraction(_ overSpeed: Int) {
        infractions.append(overSpeed)
        print("Speeding infraction recorded: \(overSpeed) km/h over the limit")
    }
    
    @State private var startTime: Date?
    @State private var elapsedTime: TimeInterval?
    

    
    init(locationName: String) {
        self.locationName = locationName
        _proximityManager = StateObject(wrappedValue: ProximityManager(stopSigns: [], trafficLights: [])) // Default empty
    }
    
    var coordinates: [CLLocationCoordinate2D] {
        let coords = locationData?.locations.map {
            CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
        } ?? []
        return coords
    }
    
    var body: some View {
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
            
            // Speed Overlay
            VStack {
                HStack {
                    Spacer()
                    SpeedOverlay(
                        speed: locationManager.currentSpeed,
                        speedLimit: locationManager.speedLimit,
                        onInfraction: handleSpeedingInfraction
                    )
                    .padding()
                }
                Spacer()
            }
            
           /* VStack {
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
            }*/
            // Floating Instructions Overlay
                        VStack {
                            Spacer()
                            VStack(alignment: .leading, spacing: 10) {
                                if isStarted{
                                    HStack{
                                        Spacer()
                                        
                                        Text("Instructions")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                    }
                                    Text(instructionManager.currentInstruction)
                                        .font(.body)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.leading)
                                        .lineSpacing(4)
                                    
                                    Text("Recognized Text: \(speechRecognizerManager.recognizedText)")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .lineLimit(2)
                                }
                                
                                HStack {
                                    Button(action: {
                                        if !isStarted && !isRouteButtonToggled{
                                                    // First click: Start the route
                                                    if proximityManager.isWithinStartLocation {
                                                        isStarted = true
                                                        isRouteButtonToggled = true
                                                        locationManager.startUpdatingLocation()
                                                        print("Route started.")
                                                    } else {
                                                        isShowingProximityAlert = true
                                                    }
                                                } else if isStarted {
                                                    // Second click: End the route and go to results page
                                                    isStarted = false
                                                    locationManager.stopUpdatingLocation()
                                                    isRouteButtonToggled = true
                                                    print("Route ended.")
                                                    isShowingResultsView = true
                                                }
                                        
                                    }) {
                                        Text(isRouteButtonToggled ? "End Route" : "Start Route")
                                            .font(.headline)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(isRouteButtonToggled ? Color.red : Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.black.opacity(0.75)) // Dark background with opacity
                            .cornerRadius(16)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 20)
                        }
                    
        }
        .toolbarBackground(Color("UIBlack"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationDestination(isPresented: $isShowingResultsView) {
            ResultsView(checklistItems: speechRecognizerManager.checklist, infractions: infractions)
                  }
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
        
//        .sheet(isPresented: $isShowingRouteSheet) {
//            RouteSheetView(currentInstruction: $instructionManager.currentInstruction, recognizedText: $speechRecognizerManager.recognizedText, showRouteAlert: $isShowingRouteAlert, isNotInRoute: $proximityManager.isNotInRoute, onCancel: {
//                locationManager.stopUpdatingLocation()
//                speechRecognizerManager.stopRecording()
//                isShowingRouteSheet = false
//                isStarted = false
//                isShowingResultsView = true // Trigger navigation to ResultsView
//            })
//            .presentationDetents([.medium, .fraction(0.5)])
//            .interactiveDismissDisabled()
//        }
//        .background(
//            NavigationLink(destination: ResultsView(checklistItems: speechRecognizerManager.checklist, infractions: infractions), isActive: $isShowingResultsView) {
//                EmptyView()
//            }
//        )
    }
}
