import SwiftUI

struct DashboardView: View {
    
    @ObservedObject var firebaseManager = FirebaseManager()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                //MARK: Welcome Header
                VStack(alignment: .leading) {
                    Text("Welcome,")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Text("take a look at your updated metrics.")
                        .font(.body)
                        .foregroundColor(.black.opacity(0.7))
                    
                    Text("This page is still a work in progress.")
                        .foregroundColor(.red)
                    
                }
                .padding(.horizontal, 20)
                
                //MARK: Graphs (Placeholder)
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .frame(height: 200)
                    .shadow(radius: 5)
                    .overlay(
                        Text("Performance Trend Graph")
                            .font(.headline)
                            .foregroundColor(.black)
                    )
                    .padding(.horizontal, 20)
            }
            
            //MARK: Details for Test Center
            
            VStack(spacing: 0){
                TabView {
                    ForEach(firebaseManager.testCenters, id: \.name) { locationData in
                        HStack{
                            
                            Spacer()
                            
                            VStack(alignment: .center) {
                                Text("\(locationData.name)")
                                    .font(.headline)
                                
                                Text("Stop Signs: \(locationData.stopSigns.count)")
                                    .font(.subheadline)
                                
                                Text("Traffic Lights: \(locationData.trafficLights.count)")
                                    .font(.subheadline)
                                
                                Text("Instructions: \(locationData.tests.count)")
                                    .font(.subheadline)
                            }//VStack
                            Spacer()
                        }//HStack
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(height: 250)
                .padding(.horizontal, 20)
                
                //MARK: Practice Session Carousel
                
                TabView {
                    if firebaseManager.sessions.isEmpty {
                        Text("You have no current sessions")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    } else {
                        ForEach(firebaseManager.sessions, id: \.date) { session in
                            VStack(alignment: .leading, spacing: 5) {
                                
                                Text("Location: \(session.location)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text("Date: \(session.date.formatted())")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text("Checklist Items:")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                ForEach(session.checklist, id: \.name) { item in
                                    HStack {
                                        Text(item.name)
                                            .font(.body)
                                            .foregroundColor(.white)
                                        Spacer()
                                        Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(item.isChecked ? .green : .red)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.black)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(height: 250)
                .padding(.horizontal,10)
                
            }//VStack
            
        }// End of ScrollView
        .navigationBarBackButtonHidden(true)
        .onAppear {
            firebaseManager.fetchSessions()
            firebaseManager.fetchTestCenters()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: LocationsView()){
                    Image(systemName: "map.fill")
                        .foregroundColor(.white)
                }
            }
        }
        .background(Color("UIBlue").edgesIgnoringSafeArea(.all))
        .toolbarBackground(Color("UIBlack"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }//BodyView
    
    
}//End of Function

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
