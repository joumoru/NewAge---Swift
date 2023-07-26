import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @ObservedObject var appDelegate: NewAgeApp
    var body: some View {
        ZStack {
            backgroundView
            
            VStack {
                Spacer()
                
                VStack {
                    Text("Login")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    TextField("Username", text: $username)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .padding(.bottom)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .padding(.bottom)
                    
                    Button(action: {
                        // Perform login action here
                        // For now, we'll just set isLoggedIn to true
                        appDelegate.isLoggedIn = true
                    }) {
                        Text("Login")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.bottom)
                }
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
    
    private var backgroundView: some View {
        LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        let newAgeApp = NewAgeApp()
        LoginView(appDelegate: newAgeApp).environmentObject(newAgeApp)
    }
}
