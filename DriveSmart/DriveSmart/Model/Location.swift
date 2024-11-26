import CoreLocation

struct LocationData {
    var name: String
    var locations: [Location] // Coordinates
    var trafficLights: [CLLocation]
    var stopSigns: [CLLocation]
}

struct Location {
    var latitude: Double
    var longitude: Double
    var instruction: String
}
