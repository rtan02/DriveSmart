import SwiftUI

//This page is just a placeholder
//The actual view would be an API call to Tableau and it will use their dashboard

struct DashboardView: View {
    var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Welcome Header
                    VStack(alignment: .leading) {
                        Text("Welcome,")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        Text("take a look at your updated metrics.")
                            .font(.body)
                            .foregroundColor(.black.opacity(0.7))
                    }
                    .padding(.horizontal, 20)
                    
                    // Performance Trend Graph (Placeholder)
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
                    
                    // Practice and Record Summary Cards
                    HStack(spacing: 20) {
                        // Practice Card
                        VStack {
                            Text("You’ve practiced")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            Text("4")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .padding(.vertical, 5)
                            
                            Text("time(s) at Oakville")
                                .font(.body)
                                .foregroundColor(.black.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.3))
                        .cornerRadius(15)
                        
                        // Record Card
                        VStack {
                            Text("On 2024-10-18")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            Text("you had the highest score record.")
                                .font(.body)
                                .foregroundColor(.black.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                    }
                    .padding(.horizontal, 20)
                    
                    // Weakness Pie Chart (Placeholder)
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .frame(height: 200)
                        .shadow(radius: 5)
                        .overlay(
                            VStack {
                                Text("Weaknesses")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                // Placeholder for Pie Chart Legend
                                HStack {
                                    Circle().fill(Color.purple).frame(width: 10, height: 10)
                                    Text("Braking").font(.caption).foregroundColor(.black)
                                    
                                    Circle().fill(Color.blue).frame(width: 10, height: 10)
                                    Text("Speed Control").font(.caption).foregroundColor(.black)
                                    
                                    Circle().fill(Color.orange).frame(width: 10, height: 10)
                                    Text("Smooth Braking").font(.caption).foregroundColor(.black)
                                    
                                    Circle().fill(Color.pink).frame(width: 10, height: 10)
                                    Text("Checklist Completion").font(.caption).foregroundColor(.black)
                                }
                                .padding(.top, 10)
                            }
                                .padding()
                        )
                        .padding(.horizontal, 20)
                }
                .padding(.vertical, 20)
            }
            .navigationBarBackButtonHidden(true)
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
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
