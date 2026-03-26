import WidgetKit
import SwiftUI

// MARK: - Widget Bundle

@main
struct CountdownWidgetBundle: WidgetBundle {
    var body: some Widget {
        CountdownEventWidget()
        if #available(iOS 17.0, *) {
            CountdownLiveActivity()
        }
    }
}
