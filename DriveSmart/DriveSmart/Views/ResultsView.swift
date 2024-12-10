//Created by: Melissa Munoz

import SwiftUI

struct ResultsView: View {
    var checklistItems: [ChecklistItem]
    @ObservedObject var locationManager: LocationManager

    var body: some View {
        ZStack {
            VStack {
                WaveShape()
                    .fill(Color.white)
                    .frame(height: 600)
                    .edgesIgnoringSafeArea(.top)
                Spacer()
            }
            
            VStack {
                ScrollView {
                    Spacer()
                    Image("result")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                    Spacer()
                    
                    HStack {
                        Text("Great Job!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding(.leading, 50)
                    
                    HStack {
                        Text("Here's the result of your drive:")
                            .font(.title3)
                            .foregroundColor(.black)
                            .padding(.bottom, 50)
                        Spacer()
                    }
                    .padding(.leading, 50)
                    
                    // CHECKLIST ITEMS
                    VStack(alignment: .leading, spacing: 10) {
                        Text("G2 Driving Checklist")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        ForEach(checklistItems) { item in
                            HStack {
                                Image(systemName: item.isChecked ? "checkmark.square.fill" : "square")
                                    .foregroundColor(item.isChecked ? .green : .black)
                                
                                Text(item.name)
                                    .font(.body)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.horizontal, 20)
                    
                    // DETAILS SECTION
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Details")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        VStack(alignment: .leading) {
                            ForEach(generateInfractionSummary(), id: \.self) { summary in
                                Text("• \(summary)")
                                    .padding(.bottom, 2)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Dashboard Button
                    NavigationLink(destination: HomePageView()) {
                        Text("Return Home")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(10)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .background(Color("UIBlue").edgesIgnoringSafeArea(.all))
        .toolbarBackground(Color("UIBlack"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
    
    private func generateInfractionSummary() -> [String] {
        let speedingCount = locationManager.infractions.filter { $0.contains("Speeding") }.count
        let suddenAccelerationCount = locationManager.infractions.filter { $0.contains("Sudden Acceleration") }.count
        let suddenBrakingCount = locationManager.infractions.filter { $0.contains("Sudden Braking") }.count
        let excessiveTurnCount = locationManager.infractions.filter { $0.contains("Excessive speed on turn") }.count
        let failureToStopCount = locationManager.infractions.filter { $0.contains("Failure to stop") }.count
        
        var summary: [String] = []
        
        if speedingCount > 0 {
            summary.append("You exceeded the speed limit \(speedingCount) times.")
        }
        if suddenAccelerationCount > 0 {
            summary.append("You accelerated suddenly \(suddenAccelerationCount) times.")
        }
        if suddenBrakingCount > 0 {
            summary.append("You braked suddenly \(suddenBrakingCount) times.")
        }
        if excessiveTurnCount > 0 {
            summary.append("You went too fast on a turn \(excessiveTurnCount) times.")
        }
        if failureToStopCount > 0 {
            summary.append("You failed to stop at waypoints \(failureToStopCount) times.")
        }
        
        return summary.isEmpty ? ["No infractions recorded."] : summary
    }
}
