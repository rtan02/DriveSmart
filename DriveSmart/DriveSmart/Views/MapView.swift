////Created by: Melissa Munoz
//
//import SwiftUI
//import MapKit
//import CoreLocation
//
//struct MapView: UIViewRepresentable {
//    var coordinates: [CLLocationCoordinate2D]
//    var userLocation: CLLocationCoordinate2D?
//    
//    @ObservedObject var firebaseManager: FirebaseManager
//
//    
//    func makeUIView(context: Context) -> MKMapView {
//        let mapView = MKMapView()
//        mapView.delegate = context.coordinator
//        
//        // Enable traffic overlay
//        mapView.showsTraffic = true
//        mapView.isZoomEnabled = true
//        mapView.isScrollEnabled = true
//        mapView.mapType = .standard
//        mapView.showsUserLocation = true
//        
//        addRoutes(to: mapView) //Add Routes to Map
//        addFirebaseAnnotations(to: mapView)
////        addTrafficAnnotations(to: mapView)  // Add Traffic Lights
//        
//        let region = MKCoordinateRegion(center: coordinates.first ?? CLLocationCoordinate2D(), latitudinalMeters: 5000, longitudinalMeters: 5000)
//        mapView.setRegion(region, animated: true)
//        
//        return mapView
//    }
//    
//    func updateUIView(_ uiView: MKMapView, context: Context) {
//        
//        if let userLocation = userLocation {
//                   uiView.setCenter(userLocation, animated: true)
//               }
//               
//               // Clear existing annotations before adding updated ones
//               uiView.removeAnnotations(uiView.annotations)
//               addFirebaseAnnotations(to: uiView)
////        // Update user location on the map if available
////        if let userLocation = userLocation {
////            uiView.setCenter(userLocation, animated: true)
////        }
//    }
//    
//    private func addRoutes(to mapView: MKMapView) {
//        if coordinates.count >= 2 {
//            for i in 0..<(coordinates.count - 1) {
//                let sourcePlacemark = MKPlacemark(coordinate: coordinates[i])
//                let destinationPlacemark = MKPlacemark(coordinate: coordinates[i + 1])
//                
//                let request = MKDirections.Request()
//                request.source = MKMapItem(placemark: sourcePlacemark)
//                request.destination = MKMapItem(placemark: destinationPlacemark)
//                request.transportType = .automobile
//                
//                let directions = MKDirections(request: request)
//                directions.calculate { response, error in
//                    if let error = error {
//                        print("Error calculating directions:", error.localizedDescription)
//                        return
//                    }
//                    if let route = response?.routes.first {
//                        mapView.addOverlay(route.polyline)
//                    }
//                }
//            }
//        }
//    }
//    
//    private func addFirebaseAnnotations(to mapView: MKMapView) {
//            // Traffic Lights Annotations
//            for coordinate in firebaseManager.trafficLights {
//                let annotation = MKPointAnnotation()
//                annotation.coordinate = coordinate
//                annotation.title = "Traffic Light"
//                mapView.addAnnotation(annotation)
//            }
//            
//            // Stop Signs Annotations
//            for coordinate in firebaseManager.stopSigns {
//                let annotation = MKPointAnnotation()
//                annotation.coordinate = coordinate
//                annotation.title = "Stop Sign"
//                mapView.addAnnotation(annotation)
//            }
//        
//        //Test
//        for testLocation in firebaseManager.tests {
//                let annotation = MKPointAnnotation()
//                annotation.coordinate = CLLocationCoordinate2D(latitude: testLocation.latitude, longitude: testLocation.longitude)
//                annotation.title = testLocation.instruction
//                mapView.addAnnotation(annotation)
//            }
//        }
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    class Coordinator: NSObject, MKMapViewDelegate {
//        var parent: MapView
//        
//        init(_ parent: MapView) {
//            self.parent = parent
//        }
//        
//        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//            if let polyline = overlay as? MKPolyline {
//                let renderer = MKPolylineRenderer(polyline: polyline)
//                renderer.strokeColor = .blue
//                renderer.lineWidth = 4.0
//                return renderer
//            }
//            return MKOverlayRenderer(overlay: overlay)
//        }
//        
//        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//            if annotation is MKUserLocation {
//                return nil // Use default user location
//            }
//            
//            let identifier = "TrafficAnnotation"
//            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
//            if annotationView == nil {
//                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//                annotationView?.canShowCallout = true
//            } else {
//                annotationView?.annotation = annotation
//            }
//            
//            return annotationView
//        }
//    }
//}
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
        
        addRoutes(to: mapView) // Add Routes to Map
        addFirebaseAnnotations(to: mapView) // Add Firebase Annotations
        
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
        
        // Test Location Annotations
        for testLocation in firebaseManager.tests {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: testLocation.latitude, longitude: testLocation.longitude)
            annotation.title = "Test Location"
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
            
            let identifier = "CustomAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            // Create a custom annotation view if it's not already created
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            } else {
                annotationView?.annotation = annotation
            }
            
            // Resize images before assigning them to annotations
            if let annotation = annotationView?.annotation {
                var imageName = ""
                
                if annotation.title == "Stop Sign" {
                    imageName = "stop_sign.png"
                } else if annotation.title == "Traffic Light" {
                    imageName = "traffic_light.png"
                } else if annotation.title == "Test Location" {
                    imageName = "test_location.png"
                }
                
                // Resize the image
                if let image = UIImage(named: imageName) {
                    annotationView?.image = resizeImage(image, targetSize: CGSize(width: 30, height: 30)) // Resize to 30x30
                }
                
                annotationView?.canShowCallout = true
            }
            
            return annotationView
        }
        
        // Helper function to resize images
        func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
            let size = image.size
            let widthRatio  = targetSize.width  / size.width
            let heightRatio = targetSize.height / size.height
            let scaleFactor = min(widthRatio, heightRatio)
            let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return resizedImage ?? image
        }
    }
}
