import SwiftUI

struct LocationsView: View {
    var body: some View {
            VStack {
                Spacer()
                
                Image("car")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                

                Text("Where would you like to test today?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding()

                Spacer()

                // Buttons for location selection
                VStack(spacing: 20) {
                    NavigationLink(destination: Text("Oakville Test Screen")) {
                        LocationButton(title: "Oakville")
                    }
                    NavigationLink(destination: Text("Mississauga Test Screen")) {
                        LocationButton(title: "Mississauga")
                    }
                    NavigationLink(destination: Text("Brampton Test Screen")) {
                        LocationButton(title: "Brampton")
                    }
                }
                Spacer()
        }
            .background(Color("UIBlue").edgesIgnoringSafeArea(.all))
            .toolbarBackground(Color("UIBlack"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}

struct LocationButton: View {
    var title: String

    var body: some View {
        Text(title)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .foregroundColor(.black)
            .cornerRadius(8)
            .shadow(radius: 3)
            .padding(.horizontal, 40)
    }
}

struct LocationsView_Previews: PreviewProvider {
    static var previews: some View {
        LocationsView()
    }
}
