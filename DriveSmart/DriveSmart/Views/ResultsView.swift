//Created by: Melissa Munoz

import SwiftUI

struct ResultsView: View {
    var checklistItems: [ChecklistItem]

    
    var body: some View {
        ZStack {
            VStack{
                WaveShape()
                    .fill(Color.white)
                    .frame(height: 600)
                    .edgesIgnoringSafeArea(.top)
                Spacer()
            }
            
            VStack {
                ScrollView{
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
                        
                        Text("On (-64, 64) you were at 80 speed when you were supposed to be at 50.")
                            .font(.body)
                            .foregroundColor(.black.opacity(0.7))
                        
                        Text("It took you 30 min to complete this driving test.")
                            .font(.body)
                            .foregroundColor(.black.opacity(0.7))
                        
                        Text("On (-64, 70), you did not do a complete stop.")
                            .font(.body)
                            .foregroundColor(.black.opacity(0.7))
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Dashboard Button
                    NavigationLink(destination: DashboardView()) {
                        Text("Return Home")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(100)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .background(Color("UIBlue").edgesIgnoringSafeArea(.all))
        .toolbarBackground(Color("UIBlack"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}



