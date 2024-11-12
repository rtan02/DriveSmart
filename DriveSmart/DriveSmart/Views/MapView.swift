//Created by: Melissa Munoz

import SwiftUI
import MapKit
import CoreLocation

struct MapView: UIViewRepresentable {
    var coordinates: [CLLocationCoordinate2D]
    var userLocation: CLLocationCoordinate2D?
    
    @ObservedObject var firebaseManager: FirebaseManager

    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        // Enable traffic overlay
        mapView.showsTraffic = true
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.mapType = .standard
        mapView.showsUserLocation = true
        
        addRoutes(to: mapView) //Add Routes to Map
        addFirebaseAnnotations(to: mapView)
//        addTrafficAnnotations(to: mapView)  // Add Traffic Lights
        
        let region = MKCoordinateRegion(center: coordinates.first ?? CLLocationCoordinate2D(), latitudinalMeters: 5000, longitudinalMeters: 5000)
        mapView.setRegion(region, animated: true)
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        
        if let userLocation = userLocation {
                   uiView.setCenter(userLocation, animated: true)
               }
               
               // Clear existing annotations before adding updated ones
               uiView.removeAnnotations(uiView.annotations)
               addFirebaseAnnotations(to: uiView)
//        // Update user location on the map if available
//        if let userLocation = userLocation {
//            uiView.setCenter(userLocation, animated: true)
//        }
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
                    if let error = error {
                        print("Error calculating directions:", error.localizedDescription)
                        return
                    }
                    if let route = response?.routes.first {
                        mapView.addOverlay(route.polyline)
                    }
                }
            }
        }
    }

    
    //MARK: These will be loaded from the cloud
//    private func addTrafficAnnotations(to mapView: MKMapView) {
//        // Hardcoded Annotations
//        let stopSigns = [
//            CLLocationCoordinate2D(latitude: 43.41172587297663, longitude: -79.73182668583425),
//            CLLocationCoordinate2D(latitude: 43.41252410618511, longitude: -79.73163606984338)
//        ]
//        
//        let trafficLights = [
//            CLLocationCoordinate2D(latitude: 43.42181176989304, longitude: -79.72189370556212),
//            CLLocationCoordinate2D(latitude: 43.42893241854303, longitude: -79.73115138899801)
//        ]
//        
//        //Traffic Light Annotations
//        for coordinate in trafficLights {
//            let annotation = MKPointAnnotation()
//            annotation.coordinate = coordinate
//            annotation.title = "Traffic Light"
//            mapView.addAnnotation(annotation)
//        }
//        
//        //Stop Sign Annotations
//        for coordinate in stopSigns {
//            let annotation = MKPointAnnotation()
//            annotation.coordinate = coordinate
//            annotation.title = "Stop Sign"
//            mapView.addAnnotation(annotation)
//        }
//    }
    
    private func addFirebaseAnnotations(to mapView: MKMapView) {
            // Traffic Lights Annotations
            for coordinate in firebaseManager.trafficLights {
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "Traffic Light"
                mapView.addAnnotation(annotation)
            }
            
            // Stop Signs Annotations
            for coordinate in firebaseManager.stopSigns {
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "Stop Sign"
                mapView.addAnnotation(annotation)
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
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil // Use default user location
            }
            
            let identifier = "TrafficAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }
            
            return annotationView
        }
    }
}
