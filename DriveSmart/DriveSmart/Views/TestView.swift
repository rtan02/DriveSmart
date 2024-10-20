import SwiftUI
import CoreLocation

struct TestView: View {
    @State private var isStarted = false
    @State private var showRouteSheet = false
    @State private var currentInstruction = "Proceed to the start location."
    @State private var showResultsView = false // State variable to control navigation to ResultsView
    
    
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        let oakvilleLocation = [
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
        
        let coordinates = oakvilleLocation.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        
        ZStack {
            MapView(coordinates: coordinates, userLocation: locationManager.currentLocation?.coordinate)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                Button(action: {
                    isStarted = true
                    showRouteSheet = true
                    locationManager.startUpdatingLocation()
                    updateInstruction()
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
            }
        }
        .onDisappear {
            locationManager.stopUpdatingLocation()
        }
        .sheet(isPresented: $showRouteSheet) {
            RouteSheetView(currentInstruction: $currentInstruction, onCancel: {
                //When you stop the route and dismiss the sheet, reset everything
                locationManager.stopUpdatingLocation()
                showRouteSheet = false
                isStarted = false
                currentInstruction = "Proceed to the start location."
                showResultsView = true // Trigger navigation to ResultsView
                
            })
            .presentationDetents([.medium, .fraction(0.5)])
        }.background(
            //THIS WILL BE CALLED UPON THE SHOWRESULTSVIEW HAS BEEN ACTIVE
            NavigationLink(destination: ResultsView(), isActive: $showResultsView) {
                EmptyView()
            }
        )
    }
    
    //Logic for driving instructions here...
    //Still need to figure out how to implement this logic. The results page should appear as soon as user is done the route. How to implement this?
    private func updateInstruction() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            currentInstruction = "Turn left at the next intersection."
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            currentInstruction = "You are approaching the destination."
        }
    }
}

//SHEET
struct RouteSheetView: View {
    @Binding var currentInstruction: String
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
    }
}

