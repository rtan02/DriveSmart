import SwiftUI

struct LocationsView: View {
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
                Spacer()
                Image("car")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: 200)
                
                HStack{
                    Text("Testing Centers")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.leading, 50)
                
                HStack{
                    Text("Where would you like to test today?")
                        .font(.title3)
                        .foregroundColor(.black)
                        .padding(.bottom, 50)
                    Spacer()
                }
                .padding(.leading, 50)

                VStack(spacing: 20) {
                    
                    //Oakville
                    NavigationLink(destination:TestView()){
                        Text("Oakville")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(8)
                            .shadow(radius: 3)
                            .padding(.horizontal, 40)
                    }
                    
                    //Mississauga
                    NavigationLink(destination:TestView()){
                        Text("Mississauga")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(8)
                            .shadow(radius: 3)
                            .padding(.horizontal, 40)
                    }
                    
                    //Brampton
                    NavigationLink(destination:TestView()){
                        Text("Brampton")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(8)
                            .shadow(radius: 3)
                            .padding(.horizontal, 40)
                    }
                    
                    
                    
                }
                Spacer()
            }
        }
        .background(Color("UIBlue").edgesIgnoringSafeArea(.all))
        .toolbarBackground(Color("UIBlack"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

struct LocationsView_Previews: PreviewProvider {
    static var previews: some View {
        LocationsView()
    }
}
