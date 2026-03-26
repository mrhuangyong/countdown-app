import SwiftUI

@main
struct CountdownApp: App {
    @State private var eventStore = EventStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(eventStore)
                .onAppear {
                    Task {
                        await NotificationService.shared.requestPermission()
                    }
                }
        }
    }
}
