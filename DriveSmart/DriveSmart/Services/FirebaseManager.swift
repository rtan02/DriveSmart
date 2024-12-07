import FirebaseFirestore
import CoreLocation
import MapKit

class FirebaseManager: ObservableObject {
    private var db = Firestore.firestore()
    
    //To get location data specific information
    @Published var stopSigns: [CLLocationCoordinate2D] = []
    @Published var trafficLights: [CLLocationCoordinate2D] = []
    @Published var tests: [Location] = [] // Make sure you have tests as Location objects
    
    //To get all data
    @Published var sessions: [Session] = []
    @Published var testCenters: [LocationData] = []

    //MARK: For Routing
    func fetchLocationData(for locationName: String, completion: @escaping (LocationData?) -> Void) {
        db.collection("TestCenters").whereField("name", isEqualTo: locationName).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                completion(nil)
                return
            }

            if let documents = querySnapshot?.documents, !documents.isEmpty {
                let document = documents.first
                let data = document?.data()
                
                // Fetch locations
                let locationsData = data?["locations"] as? [[String: Any]] ?? []
                let locations = locationsData.map { dict -> Location in
                    let latitude = dict["latitude"] as? Double ?? 0
                    let longitude = dict["longitude"] as? Double ?? 0
                    let instruction = dict["instruction"] as? String ?? ""
                    return Location(latitude: latitude, longitude: longitude, instruction: instruction)
                }
                
                // Fetch tests
                let testsData = data?["tests"] as? [[String: Any]] ?? []
                let tests = testsData.map { dict -> Location in
                    let latitude = dict["latitude"] as? Double ?? 0
                    let longitude = dict["longitude"] as? Double ?? 0
                    let instruction = dict["instruction"] as? String ?? ""
                    return Location(latitude: latitude, longitude: longitude, instruction: instruction)
                }
                
                // Other fields (traffic lights, stop signs)
                let trafficLightsData = data?["trafficLights"] as? [[String: Double]] ?? []
                let trafficLights = trafficLightsData.map { CLLocation(latitude: $0["latitude"] ?? 0, longitude: $0["longitude"] ?? 0) }
                let stopSignsData = data?["stopSigns"] as? [[String: Double]] ?? []
                let stopSigns = stopSignsData.map { CLLocation(latitude: $0["latitude"] ?? 0, longitude: $0["longitude"] ?? 0) }
                
                // Update published properties for annotations
                self.trafficLights = trafficLights.map { $0.coordinate }
                self.stopSigns = stopSigns.map { $0.coordinate }
                self.tests = tests // Save the tests in the published property
                
                // Create the LocationData object
                let locationData = LocationData(
                    name: locationName,
                    locations: locations,
                    tests: tests,
                    trafficLights: trafficLights,
                    stopSigns: stopSigns
                )
                
                // Return the fetched location data
                completion(locationData)
            } else {
                print("No document found")
                completion(nil)
            }
        }
    }
    
    // Add annotation on the map for each test location
    func addAnnotationsToMap(mapView: MKMapView) {
        for testLocation in self.tests {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: testLocation.latitude, longitude: testLocation.longitude)
            annotation.title = testLocation.instruction
            mapView.addAnnotation(annotation)
        }
    }
        
    func fetchTestCenters() {
        db.collection("TestCenters").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching test centers: \(error.localizedDescription)")
                return
            }

            if let querySnapshot = querySnapshot {
                self.testCenters = querySnapshot.documents.compactMap { doc -> LocationData? in
                    let data = doc.data()
                    
                    // Parse name
                    let name = data["name"] as? String ?? "Unknown"
                    
                    // Parse locations
                    let locationsData = data["locations"] as? [[String: Any]] ?? []
                    let locations = locationsData.compactMap { dict -> Location? in
                        guard
                            let latitude = dict["latitude"] as? Double,
                            let longitude = dict["longitude"] as? Double
                        else {
                            return nil
                        }
                        let instruction = dict["instruction"] as? String ?? ""
                        return Location(latitude: latitude, longitude: longitude, instruction: instruction)
                    }
                    
                    // Parse tests
                    let testsData = data["tests"] as? [[String: Any]] ?? []
                    let tests = testsData.compactMap { dict -> Location? in
                        guard
                            let latitude = dict["latitude"] as? Double,
                            let longitude = dict["longitude"] as? Double
                        else {
                            return nil
                        }
                        let instruction = dict["instruction"] as? String ?? ""
                        return Location(latitude: latitude, longitude: longitude, instruction: instruction)
                    }
                    
                    // Parse traffic lights
                    let trafficLightsData = data["trafficLights"] as? [[String: Double]] ?? []
                    let trafficLights = trafficLightsData.compactMap { dict -> CLLocation? in
                        guard let latitude = dict["latitude"], let longitude = dict["longitude"] else {
                            return nil
                        }
                        return CLLocation(latitude: latitude, longitude: longitude)
                    }
                    
                    // Parse stop signs
                    let stopSignsData = data["stopSigns"] as? [[String: Double]] ?? []
                    let stopSigns = stopSignsData.compactMap { dict -> CLLocation? in
                        guard let latitude = dict["latitude"], let longitude = dict["longitude"] else {
                            return nil
                        }
                        return CLLocation(latitude: latitude, longitude: longitude)
                    }
                    
                    // Return LocationData object
                    return LocationData(
                        name: name,
                        locations: locations,
                        tests: tests,
                        trafficLights: trafficLights,
                        stopSigns: stopSigns
                    )
                }
            }
        }
    }


    //MARK: For Session Data
    func fetchSessions() {
            db.collection("Sessions").getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching sessions: \(error.localizedDescription)")
                    return
                }
                
                self.sessions = snapshot?.documents.compactMap { doc -> Session? in
                    let data = doc.data()
                    let checklistData = data["checklist"] as? [[String: Any]] ?? []
                    let checklist = checklistData.map { ChecklistItem(name: $0["text"] as? String ?? "", isChecked: $0["isCompleted"] as? Bool ?? false) }
                    let date = (data["date"] as? Timestamp)?.dateValue() ?? Date()
                    let location = data["location"] as? String ?? ""
                    return Session(location: location, checklist: checklist, date: date)
                } ?? []
            }
        }
    
    func saveSession(location: String, checklist: [ChecklistItem], date: Date, completion: @escaping (Bool) -> Void) {
            let sessionData: [String: Any] = [
                "location":location,
                "date": Timestamp(date: date), // Store date as a Firestore Timestamp
                "checklist": checklist.map { [
                    "text": $0.name,
                    "isCompleted": $0.isChecked
                ]}
            ]
            
            db.collection("Sessions").addDocument(data: sessionData) { error in
                if let error = error {
                    print("Error saving session: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Session saved successfully!")
                    completion(true)
                }
            }
        }
}
