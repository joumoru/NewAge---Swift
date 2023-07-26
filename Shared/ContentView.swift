import SwiftUI
import UserNotifications

struct ContentView: View {
    @State private var data: [String] = []
    @State private var showCalendar = false
    @State private var showOpenAppView = false
    @EnvironmentObject var app: NewAgeApp
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Group {
            if app.isLoggedIn {
                NavigationView {
                    ZStack {
                        backgroundView
                        
                        VStack {
                            Spacer()
                            
                            Text("Welcome, John Doe")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.top)
                            
                            Spacer()
                            
                            Button(action: {
                                showOpenAppView.toggle()
                            }) {
                                Text("Add Application")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding(.bottom)
                            .sheet(isPresented: $showOpenAppView) {
                                OpenAppView()
                            }
                            
                            Button(action: {
                                showCalendar.toggle()
                            }) {
                                Text("Show Calendar")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding(.bottom)
                            .sheet(isPresented: $showCalendar) {
                                CalendarView()
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    .navigationTitle("Home")
                    .onAppear(perform: fetchData)
                }
            } else {
                LoginView(appDelegate: app)
            }
        }
    }
    
    private var backgroundView: some View {
        LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
    }
    
    // ... fetchData and parseData functions
    func fetchData() {
        let url = URL(string: "https://marvy101.pythonanywhere.com/user/?user=")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if let data = data {
                if let dataArray = self.parseData(data) {
                    DispatchQueue.main.async {
                        self.data = dataArray
                    }
                }
            } else if let error = error {
                print("Error fetching data: \(error)")
            }
        }
        task.resume()
    }
    
    func parseData(_ data: Data) -> [String]? {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            let dataArray = json?["data"] as? [String]
            return dataArray
        } catch {
            print("Error parsing JSON: \(error)")
            return nil
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let newAgeApp = NewAgeApp()
        ContentView().environmentObject(newAgeApp)
    }
}
