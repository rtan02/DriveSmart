
import FirebaseFirestore
import CoreLocation

class FirebaseManager: ObservableObject {
    
    private var db = Firestore.firestore()
    
    @Published var stopSigns: [CLLocationCoordinate2D] = []
    @Published var trafficLights: [CLLocationCoordinate2D] = []
    
    func fetchLocationData(for locationName: String, completion: @escaping (LocationData?) -> Void) {
        
        // Where Location = "What user picked"
        
        db.collection("TestCenters").whereField("name", isEqualTo: locationName).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let documents = querySnapshot?.documents, !documents.isEmpty {
                // Take the first document matching the query
                let document = documents.first
                let data = document?.data()
                
                //Get the locations array
                           let locationsData = data?["locations"] as? [[String: Any]] ?? []
                           
                           // Map the locations to Location objects with name, latitude, and longitude
                           let locations = locationsData.map { dict -> Location in
                               let latitude = dict["latitude"] as? Double ?? 0
                               let longitude = dict["longitude"] as? Double ?? 0
                               let instruction = dict["instruction"] as? String ?? ""
                               return Location(latitude: latitude, longitude: longitude, instruction: instruction)
                           }
                
                // Extract traffic lights
                let trafficLightsData = data?["trafficLights"] as? [[String: Double]] ?? []
                let trafficLights = trafficLightsData.map { CLLocation(latitude: $0["latitude"] ?? 0, longitude: $0["longitude"] ?? 0) }
                
                // Extract stop signs
                let stopSignsData = data?["stopSigns"] as? [[String: Double]] ?? []
                let stopSigns = stopSignsData.map { CLLocation(latitude: $0["latitude"] ?? 0, longitude: $0["longitude"] ?? 0) }
                
                // Update published properties for annotations
                self.trafficLights = trafficLights.map { $0.coordinate }
                self.stopSigns = stopSigns.map { $0.coordinate }
                
                // Create the LocationData object
                let locationData = LocationData(
                    name: locationName,
                    locations: locations,
                    trafficLights: trafficLights,
                    stopSigns: stopSigns
                )
                
                // Return the fetched location data
                completion(locationData)
            } else {
                // If no matching documents found
                print("No document found")
                completion(nil)
            }
        }
    }
    
    func fetchAnnotations(for locationName: String) {
        print("Attempting to fetch document with locationName:", locationName)
        
        // Perform a query based on the name field to retrieve annotations
        db.collection("TestCenters").whereField("name", isEqualTo: locationName).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching annotations:", error.localizedDescription)
                return
            }
            
            guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                print("No annotations found for the specified location name")
                return
            }
            
//            if let document = documents.first {
//                print("Fetched annotation data:", document.data() ?? "No data found")
//            }
        }
    }
}
