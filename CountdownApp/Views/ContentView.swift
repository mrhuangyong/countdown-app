import SwiftUI

struct ContentView: View {
    @Environment(EventStore.self) private var eventStore
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            EventListView()
                .tabItem {
                    Label("倒计时", systemImage: "hourglass")
                }
                .tag(0)

            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gearshape")
                }
                .tag(1)
        }
        .tint(.accentPrimary)
    }
}
