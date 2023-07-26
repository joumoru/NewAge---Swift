import SwiftUI
import UserNotifications

struct OpenAppView: View {
    @State private var canvasReminderEnabled = false
    @State private var mapsReminderEnabled = false
    @State private var supportedApps: [App] = [
        App(name: "Safari", scheme: "http://"),
        App(name: "Mail", scheme: "mailto://"),
        App(name: "Maps", scheme: "maps://"),
        App(name: "Calendar", scheme: "calshows://"),
        App(name: "Files", scheme: "shareddocuments://"),
        App(name: "Safari", scheme: "x-web-search://"),
        App(name: "Canvas", scheme: "canvas-courses://")
    ]
    private let accessToken = "11826~op0aFipm1smGFMuGdmDQUlSSfbL0Zkc4Hi7jWh7ii8qnUheOfNEzIbZUIW1qdiGW"
    
    @Environment(\.openURL) var openURL
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                ForEach(supportedApps) { app in
                    VStack(alignment: .leading) {
                        Button(action: {
                            openApp(urlScheme: app.scheme)
                        }) {
                            Text(app.name)
                        }
                        
                        if app.name == "Canvas" || app.name == "Maps" {
                            Toggle(isOn: app.name == "Canvas" ? $canvasReminderEnabled : $mapsReminderEnabled) {
                                Text("Set Reminder")
                                    .font(.system(size: 14))
                                    .foregroundColor(.blue)
                            }
                            .onChange(of: app.name == "Canvas" ? canvasReminderEnabled : mapsReminderEnabled) { isEnabled in
                                if isEnabled {
                                    handleNotification(for: app.name)
                                } else {
                                    removeNotification(for: app.name)
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Select App", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Done")
            })
        }
    }
    func removeNotification(for app: String) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["\(app)Notification"])
    }
    func setReminderForNextCanvasTodoItem() {
        fetchCanvasTodoList { todoItems in
            guard let nextTodoItem = todoItems.first else { return }
            
            let content = UNMutableNotificationContent()
            content.title = "Canvas To-do Reminder"
            content.body = "Upcoming task: \(nextTodoItem.assignment.title)"
            content.sound = UNNotificationSound.default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3 * 60 * 60, repeats: true)
            
            let request = UNNotificationRequest(identifier: "CanvasTodoNotification", content: content, trigger: trigger)
            
            let center = UNUserNotificationCenter.current()
            center.add(request) { (error) in
                if let error = error {
                    print("Failed to add notification request: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchCanvasTodoList(completion: @escaping ([CanvasTodoItem]) -> Void) {
        let url = URL(string: "https://canvas.instructure.com/api/v1/users/self/todo")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let todoItems = try? JSONDecoder().decode([CanvasTodoItem].self, from: data) {
                DispatchQueue.main.async {
                    completion(todoItems)
                }
            } else {
                print("Error fetching Canvas to-do list: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()
    }
    
    
    func openApp(urlScheme: String) {
        if let url = URL(string: urlScheme) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func handleNotification(for app: String) {
        let content = UNMutableNotificationContent()
        
        if app == "Canvas" {
            setReminderForNextCanvasTodoItem()
        } else if app == "Maps" {
            content.title = "Maps Reminder"
            content.body = "You have a scheduled event at a location in 30 minutes!"
        } else {
            return // Do nothing if the app is not supported for reminders
        }
        
        content.sound = UNNotificationSound.default
        
        // Configure the notification to trigger based on the app
        let trigger: UNTimeIntervalNotificationTrigger
        if app == "Canvas" {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 24 * 60 * 60, repeats: false)
        } else if app == "Maps" {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30 * 60, repeats: false)
        } else {
            return // Do nothing if the app is not supported for reminders
        }
        
        // Create the request for the notification
        let request = UNNotificationRequest(identifier: "\(app)Notification", content: content, trigger: trigger)
        
        // Add the request to the notification center
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            if let error = error {
                print("Failed to add notification request: \(error.localizedDescription)")
            }
        }
    }
    
    struct CanvasTodoItem: Codable {
        let assignment: CanvasAssignment
        let contextType: String
        
        enum CodingKeys: String, CodingKey {
            case assignment
            case contextType = "context_type"
        }
    }
    
    struct CanvasAssignment: Codable {
        let id: Int
        let title: String
    }
    
    
    struct App: Identifiable {
        let id = UUID()
        let name: String
        let scheme: String
    }
    
    struct OpenAppView_Previews: PreviewProvider {
        static var previews: some View {
            OpenAppView()
        }
    }
}
