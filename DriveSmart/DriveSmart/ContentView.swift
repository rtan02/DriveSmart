

import SwiftUI
import MapKit
import CoreLocation


struct ContentView: View {
    @State private var isStarted = false

    var body: some View {
        
        let oakvilleLocation = [
            Location(latitude: 43.41172587297663, longitude: -79.73182668583425, name: "Test Center"),
            Location(latitude:43.41252410618511, longitude: -79.73163606984338, name: "Turn Left"),
            Location(latitude: 43.42181176989304, longitude:-79.72189370556212, name: "Third Line"),
            Location(latitude: 43.42893241854303, longitude: -79.73115138899801, name: "Kings College Dr"),
            Location(latitude: 43.430518018291274, longitude:  -79.73560051162885, name: "Grainer Court"),
            Location(latitude: 43.431278749509225,longitude:  -79.73653623982118, name: "Blacksmith Ln"),
            Location(latitude:43.42978292062415, longitude:-79.73688934480235, name: "King's College Dr "),
            Location(latitude: 43.42884766429311, longitude: -79.73127332105396, name: "Third Line"),
            Location(latitude: 43.41172587297663, longitude: -79.73182668583425, name: "Test Center"
            )
        ]
        let coordinates = oakvilleLocation.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        
        MapView(coordinates: coordinates)
            .edgesIgnoringSafeArea(.all)
        
        Button(action: {
                        // Start the navigation
                        isStarted = true
                    }) {
                        Text("Start Route")
                            .font(.headline)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
    }//View
}

