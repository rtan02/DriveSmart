import SwiftUI
import MapKit
import CoreLocation

struct MapView: UIViewRepresentable {
    var coordinates: [CLLocationCoordinate2D]
    var userLocation: CLLocationCoordinate2D?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.mapType = .standard
        mapView.showsUserLocation = true  // Show user's location on the map

        addRoutes(to: mapView)

        let region = MKCoordinateRegion(center: coordinates.first ?? CLLocationCoordinate2D(), latitudinalMeters: 5000, longitudinalMeters: 5000)
        mapView.setRegion(region, animated: true)
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Update user location on the map if available
        if let userLocation = userLocation {
            uiView.setCenter(userLocation, animated: true)
        }
    }
    
    private func addRoutes(to mapView: MKMapView) {
        if coordinates.count >= 2 {
            for i in 0..<(coordinates.count - 1) {
                let sourcePlacemark = MKPlacemark(coordinate: coordinates[i])
                let destinationPlacemark = MKPlacemark(coordinate: coordinates[i + 1])
                
                let request = MKDirections.Request()
                request.source = MKMapItem(placemark: sourcePlacemark)
                request.destination = MKMapItem(placemark: destinationPlacemark)
                request.transportType = .automobile
                
                let directions = MKDirections(request: request)
                directions.calculate { response, error in
                    if let route = response?.routes.first {
                        mapView.addOverlay(route.polyline)
                    }
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .blue
                renderer.lineWidth = 4.0
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}
