import SwiftUI

struct HomePageView: View {
    var body: some View {
        NavigationView{
            VStack {
                WaveShape()
                    .fill(Color.blue)
                    .frame(height: 300)
                    .edgesIgnoringSafeArea(.top)
                HStack{
                    Text("Hello,")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                }.padding(.leading, 50)
                
                HStack{
                    Text("welcome to drivesmart.")
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(.bottom, 50)
                    Spacer()
                }.padding(.leading, 50)
                
                Spacer()
                
                // Buttons
                VStack(spacing: 20) {
                    
                    //To Dashboard
                    NavigationLink(destination: DashboardView()) {
                        Text("Get Started")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 50)
                    
                    
                    NavigationLink(destination: DashboardView()) {
                        Text("Terms and Conditions")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 50)
                }
                
                Spacer()
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
    }
}

struct WaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height * 0.4))
        path.addCurve(to: CGPoint(x: rect.width, y: rect.height * 0.4),
                      control1: CGPoint(x: rect.width * 0.3, y: rect.height * 0.1),
                      control2: CGPoint(x: rect.width * 0.7, y: rect.height * 0.7))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.closeSubpath()
        return path
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}
