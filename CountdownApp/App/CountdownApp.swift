import SwiftUI

@main
struct CountdownApp: App {
    @State private var eventStore = EventStore()
    @State private var calendarService = CalendarService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(eventStore)
                .environment(calendarService)
                .onAppear {
                    Task {
                        await NotificationService.shared.requestPermission()
                    }
                }
        }
    }
}
