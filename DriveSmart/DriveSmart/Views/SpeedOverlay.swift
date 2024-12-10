import SwiftUI

struct SpeedOverlay: View {
    var speed: Double // Speed in meters per second
    var speedLimit: Double // Speed limit in km/h
    var onInfraction: (Int) -> Void // Callback to handle infractions

    var speedInKmh: Int {
        Int(speed) // Convert m/s to km/h
    }
    
    var overlayColor: Color {
        let overSpeed = speedInKmh - Int(speedLimit)
        if overSpeed > 9 {
            onInfraction(overSpeed)
            return .red // High speeding
        } else if overSpeed > 0 {
            return .yellow // Mild speeding
        } else {
            return .blue // Normal speed
        }
    }

    var body: some View {
        VStack {
            Text("\(speedInKmh)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text("km/h")
                .font(.caption)
                .foregroundColor(.white)
        }
        .padding(20)
        .background(Circle().fill(overlayColor)) // Use overlayColor here
        .shadow(radius: 10)
    }
}
